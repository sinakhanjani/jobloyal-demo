package com.jobloyal.custom.views.textwatcher;

import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;

/**
 * Created by Mikhail Isaev on 05/03/2017.
 */

public class MaskedEditTextWatcher implements TextWatcher {

    private EditText mEditText;
    private String mMask = "";
    private MaskedEditTextWatcherDelegate mDelegate;
    private boolean isUpdating;

    public MaskedEditTextWatcher(EditText editText, MaskedEditTextWatcherDelegate delegate) {
        mEditText = editText;
        mDelegate = delegate;
        mMask = delegate.maskForCountryCode();
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        if (mEditText == null || mDelegate == null) return;
        String str = s.toString();
        if (isUpdating) {
            isUpdating = false;
            return;
        }
        String masked = mask(mMask, unmask(str));
        isUpdating = true;
        mEditText.setText(masked);
        mEditText.setSelection(masked.length());
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

    @Override
    public void afterTextChanged(Editable s) {}

    private String unmask(String s) {
        s = s.replace("+", "");
        s = s.replaceAll("\\D", "");
        return s;
    }

    private String mask(String format, String text) {
        StringBuilder maskedText = new StringBuilder();
        int i = 0;
        for (char character : format.toCharArray()) {
            if (character != '#') {
                maskedText.append(character);
                continue;
            }
            try {
                maskedText.append(text.charAt(i));
            } catch (Exception e) {
                break;
            }
            i++;
        }
        return maskedText.toString();
    }
}