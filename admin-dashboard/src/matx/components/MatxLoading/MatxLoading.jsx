import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import CircularProgress from "@material-ui/core/CircularProgress";
import LinearProgress from "@material-ui/core/LinearProgress";

const useStyles = makeStyles(theme => ({
  loading: {
    top: 'calc(50% - 150px)',
    left: 0,
    right: 0,
    margin: 'auto',
    width: '19%',
    position: 'fixed',
    "& img": {
      width: '200px',
      margin: '20px auto',
      display: 'block',
    },
    "& h1" : {
      textAlign: "center",
      fontSize: '40px',
      fontWeight: 900,
      marginBottom: '25px'
    }
  }
}));

const Loading = props => {
  const classes = useStyles();

  return (
    <div className={classes.loading}>
      <img src="/assets/images/logo.png" alt="" />
      <h1>JOBLOYAL</h1>
      {/*<CircularProgress />*/}
      <LinearProgress />
    </div>
  );
};

export default Loading;
