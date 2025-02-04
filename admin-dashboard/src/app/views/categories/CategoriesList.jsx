import React, {useEffect, useState} from "react";
import SimpleCard from "../../../matx/components/cards/SimpleCard";
import Breadcrumb from "../../../matx/components/Breadcrumb";
import axios from "axios";
import {Fab, Grid, Icon, TableCell} from "@material-ui/core";
import {Link, Redirect} from "react-router-dom";
import { useHistory } from "react-router-dom";
import SuperTreeview from './SuperTreeview';
import "./treeview.scss"
import cloneDeep from 'lodash/cloneDeep';
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";
import Dialog from "@material-ui/core/Dialog";
import Snackbar from "@material-ui/core/Snackbar";
import SnackbarContent from "@material-ui/core/SnackbarContent";
import clsx from "clsx";
import IconButton from "@material-ui/core/IconButton";
import CloseIcon from "@material-ui/icons/Close";
import {amber} from "@material-ui/core/colors";
import SnackErrorVariant from "../common/SnackErrorVariant";
import AddTwoLanguageDialog from "../common/AddTwoLanguageDialog";
import ConfirmDialog from "../common/ConfirmDialog";
import EditTwoLanguageDialog from "../common/EditTwoLanguageDialog";

const fetchUserData = async (id) => {
    const response = await axios.get('/category/all');
    return response.data.data
};
const addCategory = async (data) => {
    const response = await axios.post('/category/create',{...data});
    return response.data.data
};
const deleteCategory = async (id) => {
    const response = await axios.post('/category/delete',{id});
    return response.data
};
const editTitleCategory = async (data) => {
    const response = await axios.post('/category/edit',data);
    return response.data
};
function addNewSubOnState (pid,cat,all) {
    const data = cloneDeep(all);
    for (const category of data) {
        if (category.id === pid) {
            if (category.children && category.children.length > 0) {category.children.push(cat)}
            else {category.children = [cat]}
            break
        }
        else if (category.children) {
            category.children = addNewSubOnState(pid,cat,category.children)
        }
    }
    return data
}
function editNodeTitle (pid,name,all) {
    const data = cloneDeep(all);
    for (const category of data) {
        if (category.id === pid) {
            category.name = name
            break
        }
        else if (category.children) {
            category.children = editNodeTitle(pid,name,category.children)
        }
    }
    return data
}
function deleteSubOnState (id,data) {
    for (const category of data) {
        if (category.id === id) {
            category.deleted = true
        }
        else if (category.children) {
            category.children = deleteSubOnState(id,category.children)
        }
    }
    return data
}

const Category = (props) => {
    const [category,setCategory] = useState([]);
    const [open, setOpen] = React.useState(false);
    const [openSnackError, setOpenSnackError] = React.useState(false);
    const [openDelete, setOpenDelete] = React.useState(false);
    const [titleCategoryToAdd, addTitleCategoryToAdd] = React.useState({fr:'',en: ''});
    const [parentCategoryToAdd, setParentCategoryToAdd] = React.useState({title: 'root',id:null});
    const [categoryToDelete, setCategoryToDelete] = React.useState({title: 'root',id:null});
    const [showEditDialog, setShowEditDialog] = useState(false);
    const [nodeToEdit, setNodeToEdit] = useState({title: {en: '',fr: ''}});

    let history = useHistory();

    function handleClickOpen(id,title) {
        setParentCategoryToAdd({id,title});
        setOpen(true);
    }

    function handleClickOpenDeleteDialog(id,title) {
        setCategoryToDelete({id,title});
        setOpenDelete(true);
    }

    async function editCategory(en, fr) {
        const response = await editTitleCategory({id: nodeToEdit.id, title_en: en, title_fr: fr});
        if (response.success === true) {
            const newData = editNodeTitle(nodeToEdit.id,en + " - " + fr,category);
            setCategory(newData)
            setShowEditDialog(false)
        }
    }

    async function handleAddCategory(en,fr) {
        let pid = parentCategoryToAdd.id;
        const response = await addCategory({parent: pid,title_fr: fr,title_en: en});
        if (pid != null) {
            const newData = addNewSubOnState(pid,response,category);
            setCategory(newData);
        }
        else {
            const newData = cloneDeep(category);
            newData.push(response);
            setCategory(newData)
        }
        addTitleCategoryToAdd({fr: '',en:''});
        setParentCategoryToAdd({title: 'root',id:null});
        setOpen(false);
    }

    async function handleDeleteCategory() {
        let id = categoryToDelete.id;
        const response = await deleteCategory(id);
        if (response.success === true) {
            const data = cloneDeep(category);
            const newData = deleteSubOnState(id,data)
            setCategory(newData)
        }
        else {
            setOpenSnackError(true)
        }
        setCategoryToDelete({title: 'root',id:null});
        setOpenDelete(false);
    }

    useEffect(() => {
        fetchUserData(props.id).then(r => {
            if (r) {
                setCategory(r.items)
            }
        })
    },[]);
    return (<>
                    <Fab variant="extended" aria-label="Add" style={{float: 'right'}}
                         onClick={() => {
                             handleClickOpen(null, "Root");
                         }}>
                        <Icon className="mr-8">add</Icon>
                        Add Root Category
                    </Fab>
                    <SuperTreeview
                        data={ category }
                        onUpdateCb={(updatedData) => {
                            setCategory (updatedData)
                        }}
                        isCheckable={() => {return false}}
                        deleteElement={<Icon  fontSize='small'>delete</Icon>}
                        addElement={<Icon  fontSize='small'>add</Icon>}
                        jobsElement={<Icon  fontSize='small'>work</Icon>}
                        onDeleteCb={(node) => {
                            handleClickOpenDeleteDialog(node.id, node.name)
                        }}
                        onAddCb={(node) => {
                            handleClickOpen(node.id, node.name);
                        }}
                        onJobsCb={(node) => {
                            history.push(`jobs/${node.id}`)
                        }}
                        onEditCb={(node) => {
                            setNodeToEdit({id: node.id,title: node.title})
                            setShowEditDialog(true)
                        }}
                    />

                    <AddTwoLanguageDialog
                        open={open}
                        handleClose={() => {setOpen(false);}}
                        onAddBtnPressed={async ({en, fr}) => {
                            await handleAddCategory(en,fr)
                        }}
                        dialogTitle="Add Category"
                        dialogContentText={`Adding a new Sub Category to ${parentCategoryToAdd.title}, after add category all jobber can add his jobs and services to it.`}
                    />
                    <EditTwoLanguageDialog
                        open={showEditDialog}
                        handleClose={() => {setShowEditDialog(false)}}
                        onEditBtnPressed={async ({en, fr}) => {
                            await editCategory(en,fr)
                        }}
                        oldTitle={nodeToEdit.title}
                        dialogTitle={`Edit ${nodeToEdit.title.en}`}
                        dialogContentText="Editing the title of job can confuse all jobber and user, please be careful in this operation"
                    />
                    <ConfirmDialog
                        open={openDelete}
                        handleClose={() => {setOpenDelete(false);}}
                        titleDialog={`Delete ${categoryToDelete.title}`}
                        contentDialog="You can only delete the categories that not any jobber used it till now. but categories that has not been used yet can deleted."
                        onOKPressed={async () => {
                            await handleDeleteCategory()
                        }}
                    />
                    <SnackErrorVariant
                        open={openSnackError}
                        handleClose={() => {setOpenSnackError(false)}}
                    />
                </>)
};

const CategoryList = (props) => {
    console.log(props.match.params.id);
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Category"},
                    ]}
                />
            </div>
            <div className="py-3" />

            <SimpleCard title="Categories">
                <Category />
            </SimpleCard>
        </div>
    )
};

export default CategoryList
