import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";
import Dialog from "@material-ui/core/Dialog";
import React, {useEffect, useState} from "react";


const OneLanguageDialog = (props) => {
    const {open,handleClose,okButtonPressed,editing,node} = props;
    const [title,setTitle] = useState('');

    useEffect(() => {
        if (editing) {
            setTitle(node.title)
        }
    },[node]);

    return (
        <Dialog
            open={open}
            onClose={handleClose}
            aria-labelledby="form-dialog-title"
        >
            <DialogTitle id="form-dialog-title">{editing ? "Edit Unit" : "Add New Unit"}</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    {editing ? 'edit unit may cause all report in feature be confused because only one name be saved and previous name missed' : `adding new unit not have any side effect and helps users to find units very faster`}
                </DialogContentText>
                    <TextField
                        autoFocus
                        id="name_en"
                        label="title in any language"
                        type="text"
                        defaultValue={editing && node.title}
                        variant="outlined"
                        required
                        margin="normal"
                        onChange={(e) => {setTitle(e.target.value)}}
                        fullWidth
                    />
            </DialogContent>
            <DialogActions>
                <Button variant="outlined" color="secondary" onClick={handleClose}>
                    Cancel
                </Button>
                <Button onClick={() => {
                    okButtonPressed(title)
                }} color="primary">
                    {editing ? "Edit" : "Add"}
                </Button>
            </DialogActions>
        </Dialog>
    )
}
export default OneLanguageDialog
