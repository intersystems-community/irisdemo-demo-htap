CREATE TABLE SpeedTest.Account
(
	account_id VARCHAR(36) PRIMARY KEY,
	brokerageaccountnum VARCHAR(16),
	org VARCHAR(50),
	status VARCHAR(10),
	tradingflag VARCHAR(10),
	entityaccountnum VARCHAR(16),
	clientaccountnum VARCHAR(16),
	active_date DATETIME,
	topaccountnum VARCHAR(10),
	repteamno VARCHAR(8),
	repteamname VARCHAR(50),
	office_name VARCHAR(50),
	region VARCHAR(50),
	basecurr VARCHAR(50),
	createdby VARCHAR(50),
	createdts DATETIME,
	group_id VARCHAR(50),
	load_version_no BIGINT	
)