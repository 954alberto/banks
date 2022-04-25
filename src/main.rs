use env_logger;
use json::{self, JsonValue};
use lambda_web::actix_web::{
    self, get, middleware, web, App, Error, HttpResponse, HttpServer, Responder,
};
use lambda_web::{is_running_on_lambda, run_actix_on_lambda, LambdaError};
use regex::RegexBuilder;
use serde_json;
use std::collections::HashMap;

pub fn matching_regex(bank_short: (&str, &str), message: String) -> Vec<String> {
    let bank_short_name = bank_short.0;
    let bank_long_name = bank_short.1;
    let message: &str = &message;

    let bank_short = RegexBuilder::new(bank_short_name)
        .case_insensitive(true)
        .build()
        .expect("Invalid Regex");

    let mut veky = Vec::new();
    for i in bank_short.find_iter(&message) {
        let test = i.as_str();
        let uno = message.replace(test, bank_long_name).clone();
        veky.push(uno)
    }
    return veky;
}

async fn index_banks(body: web::Bytes) -> Result<HttpResponse, Error> {
    let banks = HashMap::from([
        ("ABN", "ABN AMRO"),
        ("ING", "ING Bank"),
        ("RABO", "Rabobank"),
        ("Triodos", "Triodos Bank"),
        ("Volksbank", "de Volksbank"),
    ]);

    // body is loaded, now we can deserialize json-rust
    let result = json::parse(std::str::from_utf8(&body).unwrap()); // return Result

    let injson: JsonValue = match result {
        Ok(v) => v,
        Err(e) => json::object! {"err" => e.to_string() },
    };

    log::info!("What do we have:{}", injson);
    let key = "err";

    if injson.has_key(key) {
        log::error!("{}", injson);
    }
    let mut response_vec = Vec::new();
    for items in injson.members() {
        let message = items.to_string();
        for bank in banks.to_owned() {
            let veky = matching_regex(bank, message.to_owned());
            let mut s = Some(String::from_iter(veky));
            if let Some(s) = s.take() {
                if s.len() > 0 {
                    response_vec.push(s);
                }
            }
        }
    }
    let response_json = serde_json::to_string(&response_vec)?;
    let response = HttpResponse::Ok()
        .content_type("application/json")
        .body(response_json);

    Ok(response)
}

#[actix_web::main]
async fn main() -> Result<(), LambdaError> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let factory = move || {
        App::new()
            .wrap(middleware::Logger::default()) // enable logger
            .app_data(web::JsonConfig::default().limit(4096)) // <- limit size of the payload (global configuration)
            .service(web::resource("/banks").route(web::post().to(index_banks)))
    };

    if is_running_on_lambda() {
        log::info!("Detected AWS Lambda environment");
        log::info!("Running Actix on Lambda");
        // Run on AWS Lambda
        run_actix_on_lambda(factory).await?;
    } else {
        log::info!("Not in AWS Lambda environment");
        log::info!("Starting HTTP server at http://0.0.0.0:8080");

        // Local server
        HttpServer::new(factory)
            .bind("0.0.0.0:8080")?
            .run()
            .await?;
    }
    Ok(())
}
