package com.jobloyal.utility

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import com.jobloyal.R

class AlertDialogFactory(val context : Activity)  {

    fun confirmDialog (title : String,subTitle : String, description : String, okButtonPressed : (AlertDialog) -> (Unit), noButtonPressed : (AlertDialog) -> (Unit)) : AlertDialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(context)
        val inflater = context.layoutInflater
        val dialogView: View = inflater.inflate(R.layout.alert_confirmation_red, null)
        builder.setView(dialogView)
        val alert: AlertDialog = builder.create()
        dialogView.findViewById<TextView>(R.id.titleOfDialog)?.text = title
        dialogView.findViewById<TextView>(R.id.secondTitleTV)?.text = subTitle
        dialogView.findViewById<TextView>(R.id.descriptionTV)?.text = description
        dialogView.findViewById<Button>(R.id.yesButton)?.setOnClickListener {
            okButtonPressed(alert)
        }
        dialogView.findViewById<Button>(R.id.noButton)?.setOnClickListener {
            noButtonPressed(alert)
        }
        alert.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        return alert
    }

    fun confirmDialog (title : Int,subTitle : Int, description : Int, okButtonPressed : (AlertDialog) -> (Unit), noButtonPressed : (AlertDialog) -> (Unit)) : AlertDialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(context)
        val inflater = context.layoutInflater
        val dialogView: View = inflater.inflate(R.layout.alert_confirmation_red, null)
        builder.setView(dialogView)
        val alert: AlertDialog = builder.create()
        dialogView.findViewById<TextView>(R.id.titleOfDialog)?.setText(title)
        dialogView.findViewById<TextView>(R.id.secondTitleTV)?.setText(subTitle)
        dialogView.findViewById<TextView>(R.id.descriptionTV)?.setText(description)
        dialogView.findViewById<Button>(R.id.yesButton)?.setOnClickListener {
            okButtonPressed(alert)
        }
        dialogView.findViewById<Button>(R.id.noButton)?.setOnClickListener {
            noButtonPressed(alert)
        }
        alert.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        return alert
    }

    fun updateDialog (required : Boolean, description : String, okButtonPressed : (AlertDialog) -> (Unit), noButtonPressed : (AlertDialog) -> (Unit)) : AlertDialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(context).setCancelable(false)
        val inflater = context.layoutInflater
        val dialogView: View = inflater.inflate(R.layout.alert_update, null)
        builder.setView(dialogView)
        val alert: AlertDialog = builder.create()
        if (!required) dialogView.findViewById<TextView>(R.id.secondTitleTV)?.visibility = View.GONE
        dialogView.findViewById<TextView>(R.id.descriptionTV)?.text = description
        dialogView.findViewById<Button>(R.id.yesButton)?.setOnClickListener {
            okButtonPressed(alert)
        }
        dialogView.findViewById<Button>(R.id.noButton)?.setOnClickListener {
            noButtonPressed(alert)
        }
        alert.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        return alert
    }

    fun warningDialog (title : String = "Oops", description : String, okButtonPressed : (AlertDialog) -> (Unit)) : AlertDialog {
        val builder: AlertDialog.Builder = AlertDialog.Builder(context)
        val inflater = context.layoutInflater
        val dialogView: View = inflater.inflate(R.layout.alert_warning, null)
        builder.setView(dialogView)
        val alert: AlertDialog = builder.create()
        dialogView.findViewById<TextView>(R.id.titleOfDialog)?.text = title
        dialogView.findViewById<TextView>(R.id.descriptionTV)?.text = description
        dialogView.findViewById<Button>(R.id.okButton)?.setOnClickListener {
            okButtonPressed(alert)
        }
        alert.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        return alert
    }
}