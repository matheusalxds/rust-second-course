use std::env;
use std::sync::{Arc, Mutex};

use actix_web::Result;
use anyhow::{Error, Ok};
use tiberius::{Client, Config};
use tokio::net::TcpStream;
use tokio_util::compat::TokioAsyncWriteCompatExt;

#[derive(Clone)]
pub struct DatabaseMSSQL {
	pub client: Arc<Mutex<Client<tokio_util::compat::Compat<TcpStream>>>>,
}

impl DatabaseMSSQL {
	pub async fn init() -> Result<Self, Error> {
		dotenv::dotenv().ok();

		let conn_str = env::var("CONNECTION_STRING").expect("CONNECTION_STRING must be set!");
		let mut config = Config::from_ado_string(&conn_str)?;
		config.trust_cert();

		let tcp = TcpStream::connect(config.get_addr()).await?;
		tcp.set_nodelay(true)?;

		let client = Client::connect(config, tcp.compat_write()).await?;
		let client = Arc::new(Mutex::new(client));

		Ok(DatabaseMSSQL { client })
	}
}