%{
  title: "Recursive workflow orchestrator with Broadway",
  tags: ["workflow", "broadway"],
  published: false,
  discussion_url: "",
  description: """
  Writing workflow orchestrator
  """
}
---

## Conceptual Broadway
GenServer:(GenServerReader -> )
AMQP:(RaabmitMQProducer -> )
Source:(SourceReader -> steps -> steps -> end)


Aim : Write a workflow orchestrator that can handle recursive workflow.

1. [user_input] -> pdf (50 / min) -> image (10 / min) -> text -> search -> result

2. user onboarding 
user signup -> aadhar (verify) -> pan -> bank (verify) -> kyc (verify) -> user created

3. Scraping 

run_scraper: url -> html -> all-a[href] -> xpath -> json 

for each url in URLS: 
    run_scraper(url)

run_scraper: [100 + 10 + 10] url -> html -> all-a[href] (100) (url_broadway) -> xpath (10 / min) -> json 


4. .... 



General Design: 

1. Observability - SQL query over oban_jobs table
2. Retry 
3. Monitoring / Alerting 


Problems with basic oban: 
1. every job is oban job (which has retry)


## How to setup a basic broadway ?


## Oban and Broadway



## Scraper: Issues with Basic Broadway and Oban

## Recursive Broadway 


