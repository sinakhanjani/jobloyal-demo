package com.jobloyal.utility

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Parcelable
import android.provider.MediaStore
import android.view.View
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContentProviderCompat.requireContext
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.fragment.app.Fragment
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.jobloyal.BuildConfig
import com.jobloyal.R
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.util.ArrayList

interface PhotoPickerUtilDelegate {

    fun showProgress()
    fun dismissProgress()
    fun onReadyImage(queryImageUrl : String)
}
/*
* for camera sure you grant the permission before call this class and not grant this permission cause not any camera app appear in intent
* */
class PhotoPickerUtil(var delegate : PhotoPickerUtilDelegate, var cameraNeeded : Boolean = false) {

    lateinit var context: Context
    private var queryImageUrl: String = ""
    private var imgPath: String = ""
    private var imageUri: Uri? = null
    var onlyCamera : Boolean = false
    lateinit var pickCallback : ActivityResultLauncher<Intent>
    lateinit var pickCallbackCameraRequest : ActivityResultLauncher<String>

    fun initForFragment (fragment: Fragment) : PhotoPickerUtil {
        pickCallback = fragment.registerForActivityResult(ActivityResultContracts.StartActivityForResult()){
            if (it.resultCode == Activity.RESULT_OK)
             handleImageRequest(it.data)
        }
        if (cameraNeeded) {
            pickCallbackCameraRequest = fragment.registerForActivityResult(ActivityResultContracts.RequestPermission()){
                if (it)
                    pickCallback.launch(getPickImageIntent())
            }
        }
        return this
    }
    /*all thing is ready and you should only permission camera permission
    * <uses-permission android:name="android.permission.CAMERA" />
    * only when you want cameraNeeded = true*/
    public fun pick(context : Context) {
        this.context = context
        if (cameraNeeded) {
            pickCallbackCameraRequest.launch(Manifest.permission.CAMERA)
        }
        else {
            pickCallback.launch(getPickImageIntent())
        }
    }

    /*
    * first you call this and startActivityForResult(pickForActivity(), req_code)
    * and bellow
    * override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    *    super.onActivityResult(requestCode, resultCode, data)
    *    when (requestCode) {
    *        RES_IMAGE -> {
    *            if (resultCode == Activity.RESULT_OK) {
    *                PhotoPickerUtil.handleImageRequest(data)
    *            }
    *        }
    *    }
    *}
    * and final get Your Image in onImageReady() */
    public fun pickForActivity(context : Context) {
        this.context = context
        getPickImageIntent()
    }



    private fun isCameraPermissionGranted(requestIfNotGrant : Boolean = true): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.CAMERA
                ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun addIntentsToList(
        context: Context,
        list: MutableList<Intent>,
        intent: Intent
    ): MutableList<Intent> {
        val resInfo = context.packageManager.queryIntentActivities(intent, 0)
        for (resolveInfo in resInfo) {
            val packageName = resolveInfo.activityInfo.packageName
            val targetedIntent = Intent(intent)
            targetedIntent.setPackage(packageName)
            list.add(targetedIntent)
        }
        return list
    }

    private fun getPickImageIntent(): Intent? {
        var chooserIntent: Intent? = null
        var intentList: MutableList<Intent> = ArrayList()
        val pickIntent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
        val takePhotoIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        takePhotoIntent.putExtra(MediaStore.EXTRA_OUTPUT, setImageUri())
        if (!onlyCamera || (onlyCamera && !cameraNeeded)) intentList = addIntentsToList(context, intentList, pickIntent)
        if (cameraNeeded && isCameraPermissionGranted(false))
            intentList = addIntentsToList(context, intentList, takePhotoIntent)

        if (intentList.size > 0) {
            chooserIntent = Intent.createChooser(
                intentList.removeAt(intentList.size - 1),
                context.getString(R.string.select_capture_image)
            )
            chooserIntent!!.putExtra(
                Intent.EXTRA_INITIAL_INTENTS,
                intentList.toTypedArray<Parcelable>()
            )
        }
        return chooserIntent
    }

    private fun setImageUri(): Uri {
        val folder = File("${context.getExternalFilesDir(Environment.DIRECTORY_DCIM)}")
        folder.mkdirs()

        val file = File(folder, "Image_Tmp.jpg")
        if (file.exists())
            file.delete()
        file.createNewFile()
        imageUri = FileProvider.getUriForFile(
            context,
            BuildConfig.APPLICATION_ID + context.getString(R.string.file_provider_name),
            file
        )
        imgPath = file.absolutePath
        return imageUri!!
    }

    public fun handleImageRequest(data: Intent?) {
        val exceptionHandler = CoroutineExceptionHandler { _, t ->
            t.printStackTrace()
            delegate?.dismissProgress()
            Toast.makeText(
                context,
                t.localizedMessage ?: "someErrorOccured",
                Toast.LENGTH_SHORT
            ).show()
        }

        GlobalScope.launch(Dispatchers.Main + exceptionHandler) {
            delegate.showProgress()

            if (data?.data != null) {     //Photo from gallery
                imageUri = data.data
                queryImageUrl = imageUri?.path!!
                queryImageUrl = context.compressImageFile(queryImageUrl, false, imageUri!!)
            } else {
                queryImageUrl = imgPath ?: ""
                context.compressImageFile(queryImageUrl, uri = imageUri!!)
            }
            imageUri = Uri.fromFile(File(queryImageUrl))

            if (queryImageUrl.isNotEmpty()) {
                delegate?.showProgress()
//                Glide.with(requireActivity())
//                    .asBitmap()
//                    .diskCacheStrategy(DiskCacheStrategy.NONE)
//                    .skipMemoryCache(true)
//                    .load(queryImageUrl)
//                    .centerCrop()
//                    .circleCrop()
//                    .into(binding.avatarImageView)
                delegate?.onReadyImage(queryImageUrl)
            }
            delegate?.dismissProgress()
        }

    }

}