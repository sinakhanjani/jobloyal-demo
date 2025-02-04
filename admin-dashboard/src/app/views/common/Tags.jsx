import React from "react";
import "./Tag.scss"

const Tag = (props) => {
    return (<div className="etag">
        <span className="title">{props.title}</span>
        <i className={props.small && "small-value"}>{props.value}</i>
    </div>)
};

const PrimaryTag = (props) => {
    return (<div className="etag ptag">
        <img src={'/assets/images/coins_primary.svg'}/>
        <div className="tag-content">
            <span className="title">{props.title}</span>
            <i  className={props.small && "small-value"}>{props.value}</i>
            <i className="subvalue">{props.subvalue}</i>
        </div>
    </div>)
};

const Tags = (props) => {
    const tags = props.tags.filter(e => !e.primary).map(e => {
        return (<Tag title={e.title} value={e.value} small={props.small}/>)
    });
    const primaryTag = props.tags.filter(e => e.primary);
    if (primaryTag.length > 0) {
        tags.push((
            <PrimaryTag title={primaryTag[0].title} value={primaryTag[0].value} subvalue={primaryTag[0].subvalue} small={props.small}/>))
    }
    return tags;
};

export default Tags;
