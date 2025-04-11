# Strategy Document: Google Fiber

**Sign-off matrix:**

| Name | Team / Role | Date |
| :--- | :---------- | :--- |
|      |             |      |


**Proposer:** 
**Status:** Draft

**Primary dataset:**  `market_1`, `market_2`, `market_3`
**Secondary dataset:** No apply

**User Profiles**

- Emma Santiage, Hiring manager
- Keith Portone, Project Manager
- Minna Rah, Lead BI Analyst
- Ian Ortega, BI Analyst
- Sylvie Essa, BI Analyst
## **Dashboard Functionality**

| Dashboard Feature            | Your Request                                                                                                                                                                         |
| :--------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Reference dashboard          | The dashboard will be created from scratch to explore the number of repeat callers an their problem types in three different markets                                                 |
| Access                       | Access will be provide as read-only to the users profiles  listed above                                                                                                              |
| Scope                        | Fields include: `date`,`market`, `problem_type`, `contact_n` and `contact_n_#`                                                                                                       |
| Date filters and granularity | Data filters can be applied for: week, month, quarter<br><br>Granularity: Any char wit detailed metrics should have the ability to click on that metric to view specific information |

## **Metrics and Charts**

### **Chart 1**

| Chart Feature | Your Request                                 |
| :------------ | :------------------------------------------- |
| Chart title   | *Repeat Call by First Date*                  |
| Chart type    | Table and bar                                |
| Dimension(s)  | Day of initial call, subsequent repeat calls |
| Metric(s)     | Contact                                      |

### **Chart 2**

| Chart Feature | Your Request                                    |
| :------------ | :---------------------------------------------- |
| Chart title   | *Market and Problem Type of First Repeat Calls* |
| Chart type    | Bar and bar                                     |
| Dimension(s)  | Call type, market, contact_n_1                  |
| Metric(s)     | Contact                                         |

### **Chart 3**

| Chart Feature | Your Request              |
| :------------ | :------------------------ |
| Chart title   | *Call by Market and Type* |
| Chart type    | Table                     |
| Dimension(s)  | Market, call type and day |
| Metric(s)     | Cntact                    |

### Chart 4

| Chart Feature | Your Request                                 |
| :------------ | :------------------------------------------- |
| Chart title   | *Repeats by Day of Weeks, Month and Quarter* |
| Chart type    | Bar                                          |
| Dimension(s)  | Date, contact                                |
| Metric(s)     | Date                                         |

