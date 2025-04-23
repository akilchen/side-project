# 銀行客戶流失分析與預測 Bank Customer Churn Analysis

每間銀行都希望可以盡量留住客戶，ABC銀行也不例外，ABC銀行的客服部主管希望客戶來銀行辦理業務後還能持續往來，持續維繫客戶關係，於是請數據分析師協助了解目前流失狀況，找出提高留住率的方法。

## 專案問題與目標:

專案緣起:ABC銀行希望可以盡量留住客戶，減少客戶流失，以維繫客戶關係。<br>
專案目標:找出目前已流失客戶的特徵，和相關單位協作討論維繫策略並執行以提升客戶留存率。<br>
專案問題:<br>
  1.目前的整體流失率為何?<br>
  2.目前各客戶特徵的流失率為何?<br>
  3.那些客戶特徵和客戶流失率有關聯?<br>
  4.預測銀行客戶流失率。<br>
  5.如何提升客戶留存率?<br>

---

## 📂 資料來源

- 資料集名稱：Bank Customer Churn Dataset
- 資料來源：Kaggle(https://www.kaggle.com/datasets/gauravtopre/bank-customer-churn-dataset)
- 資料筆數:10,000筆ABC銀行客戶
- 資料欄位:
  customer_id(客戶ID)<br>
  credit_score(信用分數):數值範圍為0~1000，非實際國際信用機構(如FICO)之分數制度。<br>
  country(國家):France,Geremy,Spain 3個國家<br>
  gender(性別)<br>
  age(年齡)<br>
  tenure(往來期間，單位:年):經了解大部分國家皆以開戶日計算往來期間<br>
  balance(帳戶餘額)<br>
  products_number(本行擁有產品數量):經查詢最多4個<br>
  credit_card(本行信用卡):0=無，1=有<br>
  active_member(活躍客戶)<br>
  estimated_salary(預估年薪)<br>
  churn(流失與否):0=未流失，1=已流失<br>
---

## 🛠️ 使用平台與分析工具

- 開發平台 : Google Colab
- 資料處理與分析 : Pandas, NumPy ,statsmodels.api
- 資料視覺化 : Matplotlib
- 機器學習 : Scikit-learn, XGBoost
- 模型部署 : Pickle

---

## 🔍 分析流程

0. 讀取Kaggle資料集
1. 認識資料:欄位特徵、是否有區失值
2. 資料清理:數值資料裝箱
3. 資料分析:敘述性統計與交叉分析
4. 模型建置前準備:設定訓練集與測試集
5. 建立預測模型:Logistic Regression、Decision tree、Random Forest、Naive Bayes、XGBoost
6. 計算Accuracy, AUC及Confusion Matrix。
7. 交叉驗證(Cross-Validation):驗證模型穩定程度。
8. 模型比較(ROC):利用Accuracy, AUC畫出ROC圖，比較最佳模型。
9. 結論與建議

---

## 🤖 建立機器學習模型後比較

| 模型名稱           | 準確率 Accuracy | AUC 分數 | 準確率排名        |
|--------------------|----------------|----------|---------------------|
| Random Forest       | 0.86          | 0.83     |   1             |
| Decision Tree       | 0.85          | 0.79     |    2            |
| XGBoost             | 0.84          | 0.83     |     3           |
| Naive Bayes         | 0.83          | 0.78     |    4            |
| Logistic Regression | 0.81          | 0.75     |     5           |


📈 五個模型的 ROC 曲線圖如下：  
![ROC Curve Comparison](ROC_comparison.png.png)

---

## 📌 結論與應用建議

- 隨機森林表現最佳，適合部署於實務應用
- 年齡、年資與是否活躍會員是影響流失的重要因子
- 可結合預測結果進行「高風險客戶」分群與定向關懷
