## 正規化後table一覽

| 資料表名稱 | 說明         |  欄位內容 | 
| --- | --- | --- | 
| customer | 客戶基本資料 | customer_id(PK)：客戶ID | 
|  |  | gender：性別(Male,Female) | 
|  |  | age：年齡 | 
|  |  | country_id(FK)：國家ID | 
|  |  | estimated_salary：預估年薪(單位：歐元) | 
|  |  | tenture：往來期間(單位:年) | 
| countries | 國家標籤資訊 | country_id(PK)：國家ID | 
|  |  | country_name：國家名稱(France,Geremy,Spain) | 
| products | 客戶產品資訊 | customer_id(PK)：客戶ID | 
|  |  | products_number：擁有本行產品數量 | 
|  |  | credit_card：本行信用卡(0：無，1：有) | 
|  |  | balance：帳戶餘額(單位：歐元) | 
| credit_data | 客戶信用相關資訊 | customer_id(PK)：客戶ID | 
|  |  | credit_score：信用分數(數值範圍為0~1000，為數據集提供之模擬分數，非使用實際國際信用機構(如FICO)之分數制度。) | 
| membership | 客戶熱度資訊 | customer_id(PK)：客戶ID | 
|  |  | active_member：活躍客戶(0：非活躍，1：活躍客戶) | 
|  |  | churn：流失與否(0=未流失，1=已流失) | 


##  關聯關係
 - 一個 customer_id 對應一筆 products 資料（1 : 1）
 - 一個 country_id 可被多個客戶共用（1 : N）
 - products、credit_data、membership 均可透過 customer_id 關聯回 customer
