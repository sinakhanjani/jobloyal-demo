import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import Autocomplete from "@material-ui/lab/Autocomplete";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";
import Dialog from "@material-ui/core/Dialog";
import React, {useEffect, useState} from "react";


const UnitBaseDialog = (props) => {
    const {open,handleClose,units,okButtonPressed,editing,node} = props;
    const [unit,setUnit] = useState({title: ''});
    const [title,setTitle] = useState('');

    useEffect(() => {
        if (editing) {
            setTitle(node.title)
            console.log(node)
            if (node.unit) {
                setUnit(node.unit)
            }
            else {
                setUnit({id: null,title: 'Hour'})
            }
        }
    },[node]);

    return (
        <Dialog
            open={open}
            onClose={handleClose}
            aria-labelledby="form-dialog-title"
        >
            <DialogTitle id="form-dialog-title">{editing ? "Edit Service" : "Add New Service"}</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    {editing ? 'edit service may cause all report in feature be confused because only one name be saved and previous name missed' : `adding a new service to this job cause jobber can find faster his service, because if jobber could not find his service he has to create new one`}
                </DialogContentText>
                <div style={{display:'flex','align-items': 'center','justify-content': 'space-around'}}>
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
                        style={{width: '70%'}}
                    />
                    <Autocomplete
                        id="unit"
                        style={{width: '25%'}}
                        value={unit}
                        onChange={(event,newVal) => {
                            setUnit(newVal)
                        }}
                        getOptionLabel={(option) => option.title}
                        options={units}
                        renderInput={(params) => (
                            <TextField {...params} label="unit" margin="normal" variant="outlined" />
                        )}
                    />
                </div>
            </DialogContent>
            <DialogActions>
                <Button variant="outlined" color="secondary" onClick={handleClose}>
                    Cancel
                </Button>
                <Button onClick={() => {
                     okButtonPressed(title,unit)
                }} color="primary">
                    {editing ? "Edit" : "Add"}
                </Button>
            </DialogActions>
        </Dialog>
    )
}
export default UnitBaseDialog
