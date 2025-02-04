import Tags from "../common/Tags";
import React, {useEffect, useState} from "react";
import "./Report.scss";
import Paper from '@material-ui/core/Paper';
import {
    ArgumentAxis,
    ValueAxis,
    Chart,
    LineSeries,
    BarSeries,
    Title,
    Legend
} from '@devexpress/dx-react-chart-material-ui';
import Icon from "@material-ui/core/Icon";
import {Animation} from '@devexpress/dx-react-chart';
import axios from "axios";
import CircularProgress from "@material-ui/core/CircularProgress";
import {Link} from "react-router-dom";
import {makeStyles} from "@material-ui/styles";


const fetchData = async () => {
    const response = await axios.post("/reports");
    console.log(response);
    return response.data.data;
};


const RequestChart = (props) => {
    return (<div className="chart-box">
        <h3>Request Chart</h3>
        <p>count of cancel and accept requests</p>
        <Paper style={{width: '100%'}}>
            <Chart
                data={props.data}
            >
                <ArgumentAxis/>
                <ValueAxis/>

                <LineSeries
                    name="All Requests"
                    valueField="all"
                    argumentField="day"
                />
                <LineSeries
                    name="Done"
                    valueField="done"
                    argumentField="day"
                />
                <LineSeries
                    name="Canceled"
                    valueField="canceled"
                    argumentField="day"
                />
                <Legend position="bottom"/>
                <Animation/>
            </Chart>
        </Paper>
    </div>)
};
const JobberItem = (props) => {
    return (<Link to={`/dashboard/jobber/${props.data.jobber_id}`}>
        <div className="jobber-item">
            <img src={props.data.avatar}/>
            <div className="jobber-item-detail">
                <div className="jobber-name">{props.data.name}</div>
                <div className="jobber-meta">{props.data.meta}</div>
            </div>
            <div className="arrow-item">
                <span>{props.data.service_title}</span> <Icon>navigate_next</Icon>
            </div>
        </div>
    </Link>)
};
const JobberList = (props) => {
    return (<div className="chart-box">
        <h3>{props.title}</h3>
        <p>{props.subtitle}</p>
        <div className="jobber-list">
            {props.jobbers.map(e => {
                return (<JobberItem data={e}/>)
            })}
        </div>
    </div>)

};
const IncomeChart = (props) => {
    return (<div className="chart-box">
        <h3>Income Chart</h3>
        <p>total income from 15 days ago</p>
        <Paper>
            <Chart
                data={props.data}
            >
                <ArgumentAxis/>
                <ValueAxis max={15}/>

                <BarSeries
                    valueField="payments"
                    argumentField="day"
                />
                <Animation/>
            </Chart>
        </Paper>
    </div>)
};

const Report = (props) => {
    const [loading, setLoading] = useState(true);
    const [data, setData] = useState({});
    useEffect(() => {
        fetchData().then((response) => {
            setData(response);
            setLoading(false);
        })
    }, []);
    return (
        <>
            {loading ?  <div className='loading'>
                <CircularProgress />
                </div>:
                <div className="report-container">
                    <Tags tags={data.tags} small={true}/>
                    <div className="soft-shadow-box">
                        <RequestChart data={data.requestChart}/>
                        <JobberList jobbers={data.worstRating} title={"Worst ratings (in 7 days)"}
                                    subtitle={"jobbers that achive lowest rating"}/>
                        <IncomeChart data={data.paymentChart}/>
                        <JobberList jobbers={data.expensive} title={"The most expensive services (in 7 Day)"}
                                    subtitle={"jobbers that serve that services"}/>
                    </div>
                </div>
            }
        </>
    )
};

export default Report;
