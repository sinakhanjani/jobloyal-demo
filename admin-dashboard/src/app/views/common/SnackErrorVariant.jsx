import React, {useEffect, useState} from "react";
import SnackbarContent from "@material-ui/core/SnackbarContent";
import {amber} from "@material-ui/core/colors";
import IconButton from "@material-ui/core/IconButton";
import CloseIcon from "@material-ui/icons/Close";
import Snackbar from "@material-ui/core/Snackbar";

const SnackErrorVariant = (props) => {
    const {open, handleClose, message} = props;
    return (<Snackbar
        anchorOrigin={{
            vertical: "bottom",
            horizontal: "left"
        }}
        open={open}
        autoHideDuration={6000}
        onClose={handleClose}
    >
        <SnackbarContent
            variant="warning"
            style={{backgroundColor: amber[700]}}
            aria-describedby="client-snackbar"
            message={
                <span id="client-snackbar">
                    {message || "this operate can not be execute"}
                </span>
            }
            action={[
                <IconButton
                    key="close"
                    aria-label="Close"
                    color="inherit" >
                    <CloseIcon />
                </IconButton>
            ]}
        />
    </Snackbar>)
};

export default SnackErrorVariant
