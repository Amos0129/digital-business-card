## 屬於專案底層的各種配置
- - - 
### 資料庫相關
#### CQRSConfig
抽象類別, 配置資料庫使用者
#### JdbcDevCQRSConfig
繼承自 CQRSConfig, 使用 jdbc 進行配置
#### JndiCQRSConfig
繼承自 CQRSConfig, 使用 jndi 進行配置
#### DynamicDataSourceSetting
動態決定是否使用 queryUser

- - - 
### InterceptorConfig
配置各種自定義的過濾層

### SecurityConfig
Spring Security 配置

### SwaggerConfig
介面化 API 測試的配置