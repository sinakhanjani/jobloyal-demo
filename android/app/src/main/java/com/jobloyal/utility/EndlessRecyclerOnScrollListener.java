package com.jobloyal.utility;


import android.util.Log;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public abstract class EndlessRecyclerOnScrollListener extends RecyclerView.OnScrollListener {
//    public static String TAG = EndlessRecyclerOnScrollListener.class.getSimpleName();

    /**
     * The total number of items in the dataset after the last load
     */
    private int mPreviousTotal = 0;
    private int mItemAddedPrevious = 0;
    private boolean noLoadAnyMore = false;
    /**
     * True if we are still waiting for the last set of data to load.
     */
    private boolean mLoading = true;

    @Override
    public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
        super.onScrolled(recyclerView, dx, dy);

        if (!noLoadAnyMore) {
            int visibleItemCount = recyclerView.getChildCount();
            int totalItemCount = recyclerView.getLayoutManager().getItemCount();
            int firstVisibleItem = ((LinearLayoutManager) recyclerView.getLayoutManager()).findFirstVisibleItemPosition();

            if (mLoading) {
                if (totalItemCount > mPreviousTotal + 1) {
                    mLoading = false;
                    if (totalItemCount - mPreviousTotal < mItemAddedPrevious) {
                        noLoadAnyMore = true;
                    }
                    mItemAddedPrevious = totalItemCount - mPreviousTotal;
                    mPreviousTotal = totalItemCount;
                }
            }
            int visibleThreshold = 1;
            if (!mLoading && !noLoadAnyMore && (totalItemCount - visibleItemCount)
                    <= (firstVisibleItem + visibleThreshold)) {
                // End has been reached

                onLoadMore();

                mLoading = true;
            }
        }
    }

    public abstract void onLoadMore();
}