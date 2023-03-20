----This is a dataset from a call center company here in the united states.

--- checking the datatypes of the columns in the table
Select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Call_center'

--- creating temp table to remove irrelevant data.

create table #call_center(
    Call_Center varchar(50),
    Call_Timestamp DATETIME,
    Channel varchar(50),
    City varchar(50),
    Customer_Name varchar(50),
    Id varchar(50),
    Reason varchar(50),
    Response_Time varchar(50),
    Sentiment varchar(50),
    State varchar(50),
    Average_Call_Duration int,
    Csat_Score int  
)

--- data cleaning , data type conversions and loading data into temp table

insert into #call_center
select Call_Center,
    try_convert(date,Call_Timestamp, 103),
    Channel,
    City,
    Customer_Name,
    Id,
    Reason,
    Response_Time,
    Sentiment,
    State,
    Average_Call_Duration,
    Csat_Score
from Call_center 

--- First of all we want to see how they are doing in terms of customer sentiments?

select Sentiment, count(Sentiment) as Num_of_sentiment
from #call_center
group by Sentiment
order by Num_of_sentiment desc

--- we want to check the sentiment metrics from each state.
-- I want to see how many negative Sentiments each state has got.

select State, count(Sentiment) as Num_of_negative_sentiment
from #call_center
where Sentiment in ('Very Negative', 'Negative')
group by State 
order by Num_of_negative_sentiment desc

--- We want to check the sentiment metrics from each state, 
-- i want to see how many positive Sentiments each state has got.

select State, count(Sentiment) as Num_of_positive_sentiment
from #call_center
where Sentiment in ('Very Positive', 'Positive')
group by State 
order by Num_of_positive_sentiment desc

--- We want to see the neutral sentiments by state

select State, count(Sentiment) as Neutral_sentiment
from #call_center
where Sentiment = 'neutral'
group by State 
order by Neutral_sentiment desc

-- checking the various channels of cummincation with the customers and the number of positive and negative sentiments from the customers.

select Channel, count(Sentiment) s_count
from #call_center
where Sentiment in ('Very Positive','Positive')
group by Channel 

select Channel, count(Sentiment) s_count
from #call_center
where Sentiment in ('Very Negative', 'Negative')
group by Channel 


--- We want to check the reasons for the calls that brought these negative and very negative sentiments.

select Reason, count(Sentiment) s_count
from #call_center
where Sentiment in ('Very Negative', 'Negative')
group by Reason
order by s_count desc

--- Here we want to check for number of csat scores that were 8,9 and 10 in all the states.

select State, count(Csat_Score) as Customer_Satisfaction_score_count
from #call_center
where Csat_Score in (8,9,10)
group by State
order by Customer_Satisfaction_score_count desc

--- We want to check the count of Sentiments on the negative, very negative side and the positive, very positive side, this is enable us to see 
-- each station is really doing.

with call_c as 
(
    Select *, rn = ROW_NUMBER() OVER(partition by Sentiment order by State)
    from #call_center
) 

select State,
negative = count(case when Sentiment = 'Negative' then Sentiment end),
very_negative = count(case when Sentiment = 'very Negative' then Sentiment end),
positive = count(case when Sentiment = 'Positive' then Sentiment end),
very_positive = count(case when Sentiment = 'Very Positive' then Sentiment end),
neutral = count(case when Sentiment = 'Neutral' then Sentiment end)
from call_c 
group by State 
Order by State

---Thanks