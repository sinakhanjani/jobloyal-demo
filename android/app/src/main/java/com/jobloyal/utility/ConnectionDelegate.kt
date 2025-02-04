package com.jobloyal.utility

interface ConnectionDelegate {
    fun connectionDelegateShowNoConnection(code: Int)
    fun connectionDelegateHideNoConnection()
    fun connectionDelegateRefreshData()
}