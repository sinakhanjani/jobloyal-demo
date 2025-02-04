package com.jobloyal.user.adapter

import android.content.Context
import android.graphics.Color
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.widget.doAfterTextChanged
import androidx.recyclerview.widget.RecyclerView
import com.jobloyal.R
import com.jobloyal.databinding.ItemUserInvoiceBinding
import com.jobloyal.user.model.jobber.page.JobPageService
import com.jobloyal.utility.getFranc


class UserInvoiceAdapter(
    val items: Array<JobPageService>,
    val context: Context,
    val onChangeCount: ((position: Int) -> Unit)
) : RecyclerView.Adapter<UserInvoiceAdapter.MyViewHolder>() {

    private val activeColor = ContextCompat.getColor(context, R.color.blue_500)
    private val inactiveColor = Color.parseColor("#E7E7E7")
    var activeItem : Int = -1
    fun getServices () = items
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val binding = ItemUserInvoiceBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return MyViewHolder(binding)
    }

    override fun getItemCount(): Int {
        return items.size
    }

    override fun onViewRecycled(holder: MyViewHolder) {
        super.onViewRecycled(holder)
        holder.binding.editText.removeTextChangedListener(holder.textWatch)
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val service = items.get(position)
        if (position == items.size - 1) {
            holder.binding.editText.imeOptions = EditorInfo.IME_ACTION_DONE;
        }
        else {
            holder.binding.editText.imeOptions = EditorInfo.IME_ACTION_NEXT;
        }
        fun setActiveMode () {
            holder.binding.background.delegate.setStrokeColor(activeColor)
            holder.binding.titleOfService.setTextColor(activeColor)
            holder.binding.unit.setTextColor(activeColor)
            holder.binding.editText.setTextColor(activeColor)
            holder.binding.underline.visibility = View.VISIBLE
            holder.binding.devider.setImageResource(R.drawable.selected_ticket_background)
            holder.binding.editText.requestFocus()
            val imm: InputMethodManager? =
                context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
            imm?.showSoftInput(holder.binding.editText, InputMethodManager.SHOW_IMPLICIT)
            holder.binding.editText.setSelection(0, holder.binding.editText.text.toString().length)
        }
        fun setInactiveMode () {
            holder.binding.background.delegate.setStrokeColor(inactiveColor)
            holder.binding.titleOfService.setTextColor(Color.parseColor("#D9404040"))
            holder.binding.unit.setTextColor(Color.parseColor("#BABABA"))
            holder.binding.editText.setTextColor(Color.parseColor("#4A4A4A"))
            holder.binding.underline.visibility = View.INVISIBLE
            holder.binding.devider.setImageResource(R.drawable.ic_ticket_background)
        }
        holder.binding.editText.setText(service.count?.toString())

        if (position == activeItem)
            setActiveMode()
        else
            setInactiveMode()
        holder.binding.editText.setOnEditorActionListener { v, actionId, event ->
            val result = actionId and EditorInfo.IME_MASK_ACTION
                if (result == EditorInfo.IME_ACTION_NEXT) {
                    activeItem++
                    setInactiveMode()
                    notifyItemChanged(activeItem)
                }
            else if (result == EditorInfo.IME_ACTION_DONE) {
                    activeItem = -1
                    notifyItemChanged(position)
                }
            false
        };
        holder.textWatch = holder.binding.editText.doAfterTextChanged {
            service.count = holder.binding.editText.text.toString().toIntOrNull() ?: 0
            holder.binding.total.text = ((holder.binding.editText.text.toString().toIntOrNull() ?: 0) * (service.price ?: 0f)).getFranc()
            onChangeCount(position)
        }

        holder.binding.titleOfService.text = service.title?.capitalize()
        holder.binding.unit.text = "(${service.unit})"
        holder.binding.price.text = service.price.getFranc()
        holder.binding.total.text = ((service.count ?: 1) * (service.price ?: 0f)).getFranc()
        holder.itemView.setOnClickListener {
            val previous = activeItem
            activeItem = position
            notifyItemChanged(previous)
            setActiveMode()
        }
    }

    inner class MyViewHolder(val binding: ItemUserInvoiceBinding) : RecyclerView.ViewHolder(binding.root) {
        var textWatch : TextWatcher? = null
    }
}