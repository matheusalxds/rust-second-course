use std::io;
use std::sync::Arc;

use actix_cors::Cors;
use actix_web::{App, http::header, HttpServer, web};
use actix_web::middleware::Logger;

use api::customer_post_api::insert_into_customers_table;
use service::customer_post::CustomerPostService;

use crate::database::database::DatabaseMSSQL;

mod api;
mod database;
mod models;
mod service;

#[actix_web::main]
async fn main() -> io::Result<()> {
	let msg_error = "Failed to initialize MSSQL database";
	let db = match DatabaseMSSQL::init().await {
		Ok(db) => db,
		Err(_) => {
			println!("{}", msg_error);
			return Err(std::io::Error::new(std::io::ErrorKind::Other, msg_error));
		}
	};

	let db = Arc::new(db);
	let customer_post_service = CustomerPostService::new(db.clone());

	println!("Backend server is running on http://127.0.0.1:8080");

	HttpServer::new(move || {
		App::new()
			.app_data(web::Data::new(customer_post_service.clone()))
			.wrap(Logger::default())
			.service(
				web::scope("/api")
					.wrap(
						Cors::default()
							.allowed_origin("http://localhost:3000")
							// .allowed_origin("http://yoursite.com:3000")
							.allowed_methods(vec!["GET", "POST"])
							.allowed_headers(vec![header::AUTHORIZATION, header::ACCEPT])
							.allowed_header(header::CONTENT_TYPE)
							.max_age(3600)
					).service(insert_into_customers_table)
			)
	}).bind("127.0.0.1:8080")?
		.run()
		.await?;

	Ok(())
}
