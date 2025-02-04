import React, {useEffect, useState} from "react";
import SimpleCard from "../../../matx/components/cards/SimpleCard";
import Breadcrumb from "../../../matx/components/Breadcrumb";
import axios from "axios";
import {Grid, Icon} from "@material-ui/core";
import {Link} from "react-router-dom";
import SuperTreeview from 'react-super-treeview';
import "../categories/treeview.scss"
import Tags from "../common/Tags";
import "./PushNotification.scss";
import CircularProgress from "@material-ui/core/CircularProgress";
import { useHistory } from 'react-router-dom';


const UserDetail = (props) => {
    const [titleOfPost, setTitleOfPost] = useState("");
    const [loading, setLoading] = useState(false);
    const [contentOfPost, setContentOfPost] = useState("");
    const id = props.id;
    const history = useHistory();


    const sendNotification = () => {
        setLoading (true);
        const response = axios.post("/notification/push", {
            "user_id": id,
            "title": titleOfPost,
            "content": contentOfPost
        }).then(response => {
            setLoading(false);
            if (response.data.success) {
                setTitleOfPost("");
                setContentOfPost("");
                history.goBack();

            }
        });
    };
    return (<div className="push_message">
            <div className="white-box">
                <input
                    value={titleOfPost}
                    placeholder="title Of Message"
                    className="title-input"
                    onChange={(e) => {setTitleOfPost(e.target.value)}}
                />
            </div>

            <div className="white-box mt-2">
                        <textarea
                            value={contentOfPost}
                            placeholder="Content Of Message"
                            className="title-input"
                            onChange={(e) => {setContentOfPost(e.target.value)}}
                        />
            </div>
            <div className="right-end"> {loading ? <CircularProgress size={30} />:
                <div className="send-button" onClick={e => {
                    if (!loading) sendNotification()
                }}>
                    Send
                </div>
            }
            </div>
        </div>
    )
};

const UserInfo = (props) => {
    const s = props.match.params.s;
    const id = s.split("|")[0];
    const name = s.split("|")[1];
    return (
        <div className="m-sm-30">
            <div className="py-3" />
            <Tags tags={[{"title": "to", value: name}]}/>
            <div style={{marginTop: '20px'}}>
            <SimpleCard title="Push Notification" >
                <UserDetail id={id}/>
            </SimpleCard>
            </div>
        </div>
    )
};

export default UserInfo
