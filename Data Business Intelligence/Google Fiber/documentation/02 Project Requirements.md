# Project Requirements Document: Google Fiber

**Client/Sponsor:** Emma Santigo, Hiring Manager

**Purpose:**  As part of fictional interview process, the Fiber customer service team has asked for a dashboard using fictional call center data based on the  data they use regularly on the job to gain insights about repeat callers.  The team’s ultimate goal is to communicate with the customers to reduce the call volume and increase customer satisfaction and improve operational optimization. The dashboard should demonstrate an understanding  of this goal and provide to stakeholders insights about repeat caller volumes in different markets and the types of problems they represent.

**Key dependencies:** 

**Stakeholder requirements:**  In order to  continuously improve customer satisfaction, the dashboard must help Google Fiber decision-makers understand *how often customers are having to repeatedly call and what problem types or other factors might be influencing those calls*

- A chart or table measuring repeat calls by their first contact date (R)
- A chart  or table exploring repeat calls by market and problem type (R)
- Chart showcasing repeat calls by week, month and quarter (D)
- Provide insights into the types of customers issues that seem to generate repeat calls (D)
- Explore repeat caller trends in the three different market cities (R)
- Design charts so that stakeholder can view by week, month, quarter and year (R)

Priority: R, for required; D, for desired; and N, for nice to have.

**Success criteria:** 

- **S:** BI insights must clearly identify the specific characteristics of all a repeat calls.
- **M:** Calls should be evaluated using measurable metrics, including frequency and metrics.
- **A:** These outcomes must quantify the number of repeat callers under different circumstances to provide the Google Fiber team with insights into customers satisfaction
- **R** All metrics must support the primary question: How often are customers repeatedly contacting the customer service team?
- **T** Analyze data that spans at least one year to understand how repeat callers change over time. 

**User journeys:**  

**Assumptions:** In order to anonymize and fictionalize the data, the datasets the columns `market_1`, `market_2`, and `market_3` to indicate three different city service areas the data represents.

The data also lists five problem types:

- Type_1 is account management
- Type_2 is technician troubleshooting
- Type_3 is scheduling
- Type_4 is construction
- Type_5 is internet and wifi

Additionally, the dataset also records repeat calls over seven day periods. The initial contact date is listed as `contacts_n`. The other call columns are then `contacts_n_number` of days since first call. For example, `contacts_n_6` indicates six days since first contact.

**Compliance and privacy:** The datasets are fictionalized versions of the actual data this team works with. Because of this, the data is already anonymized and approved.

**Accessibility:** The dashboards should offer text alternatives including large print and text-to-speech.

**Roll-out plan:** The stakeholders have requested a completed BI tool in six weeks.
