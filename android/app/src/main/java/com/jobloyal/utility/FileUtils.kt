package com.jobloyal.utility


import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.util.Log
import android.webkit.MimeTypeMap
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

private const val tag = "FileUtils"

suspend fun Context.compressImageFile(
    path: String,
    shouldOverride: Boolean = true,
    uri: Uri
): String {
    return withContext(Dispatchers.IO) {
        var scaledBitmap: Bitmap? = null

        try {
            val (hgt, wdt) = getImageHgtWdt(uri)
            try {
                val bm = getBitmapFromUri(uri)
                Log.d(tag, "original bitmap height${bm?.height} width${bm?.width}")
                Log.d(tag, "Dynamic height$hgt width$wdt")
            } catch (e: Exception) {
                e.printStackTrace()
            }
            // Part 1: Decode image
            val unscaledBitmap = decodeFile(this@compressImageFile, uri, wdt, hgt, ScalingLogic.FIT)
            if (unscaledBitmap != null) {
                if (!(unscaledBitmap.width <= 800 && unscaledBitmap.height <= 800)) {
                    // Part 2: Scale image
                    scaledBitmap = createScaledBitmap(unscaledBitmap, wdt, hgt, ScalingLogic.FIT)
                } else {
                    scaledBitmap = unscaledBitmap
                }
            }

            // Store to tmp file
            val mFolder = File("$filesDir/Images")
            if (!mFolder.exists()) {
                mFolder.mkdir()
            }

            val tmpFile = File(mFolder.absolutePath, "IMG_${getTimestampString()}.png")

            var fos: FileOutputStream? = null
            try {
                fos = FileOutputStream(tmpFile)
                scaledBitmap?.compress(
                    Bitmap.CompressFormat.JPEG,
                    getImageQualityPercent(tmpFile),
                    fos
                )
                fos.flush()
                fos.close()
            } catch (e: FileNotFoundException) {
                e.printStackTrace()

            } catch (e: Exception) {
                e.printStackTrace()
            }

            var compressedPath = ""
            if (tmpFile.exists() && tmpFile.length() > 0) {
                compressedPath = tmpFile.absolutePath
                if (shouldOverride) {
                    val srcFile = File(path)
                    val result = tmpFile.copyTo(srcFile, true)
                    Log.d(tag, "copied file ${result.absolutePath}")
                    Log.d(tag, "Delete temp file ${tmpFile.delete()}")
                }
            }

            scaledBitmap?.recycle()

            return@withContext if (shouldOverride) path else compressedPath
        } catch (e: Throwable) {
            e.printStackTrace()
        }

        return@withContext ""
    }

}

@Throws(IOException::class)
fun Context.getBitmapFromUri(uri: Uri, options: BitmapFactory.Options? = null): Bitmap? {
    val parcelFileDescriptor = contentResolver.openFileDescriptor(uri, "r")
    val fileDescriptor = parcelFileDescriptor?.fileDescriptor
    var image: Bitmap? = if (options != null)
        BitmapFactory.decodeFileDescriptor(fileDescriptor, null, options)
    else
        BitmapFactory.decodeFileDescriptor(fileDescriptor)

    try {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            val exif =
                ExifInterface(fileDescriptor!!)
            val orientation: Int = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1)
            Log.d("EXIF", "Exif: $orientation")
            val matrix = Matrix()
            if (orientation == 6) {
                matrix.postRotate(90f)
            } else if (orientation == 3) {
                matrix.postRotate(180f)
            } else if (orientation == 8) {
                matrix.postRotate(270f)
            }
            image = Bitmap.createBitmap(
                image!!,
                0,
                0,
                image.width,
                image.height,
                matrix,
                true
            )
        }
    } catch (e: java.lang.Exception) {
        Log.i("dsfdfs", "sdf: " + e.message)
        e.printStackTrace()
    }
    parcelFileDescriptor?.close()
    return image
}

fun getTimestampString(): String {
    val date = Calendar.getInstance()
    return SimpleDateFormat("yyyy MM dd hh mm ss", Locale.US).format(date.time).replace(" ", "")
}


fun getMimeType(file: File): String? {
    val extension: String? = getExtension(file.name)
    return if (extension?.length ?: 0 > 0) MimeTypeMap.getSingleton()
        .getMimeTypeFromExtension(extension?.substring(1)) else "application/octet-stream"
}

/**
 * Gets the extension of a file name, like ".png" or ".jpg".
 *
 * @param uri
 * @return Extension including the dot("."); "" if there is no extension;
 * null if uri was null.
 */
fun getExtension(uri: String?): String? {
    if (uri == null) {
        return null
    }
    val dot = uri.lastIndexOf(".")
    return if (dot >= 0) {
        uri.substring(dot)
    } else {
        // No extension.
        ""
    }
}