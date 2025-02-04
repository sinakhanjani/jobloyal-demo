package com.jobloyal.network.Http

import android.content.Context
import android.util.Log
import com.jobloyal.MyApplication
import com.jobloyal.R
import com.jobloyal.utility.ConnectionDelegate
import com.jobloyal.utility.Const
import com.jobloyal.utility.Utilities.Companion.isOnline
import okhttp3.ConnectionSpec
import okhttp3.OkHttpClient
import okhttp3.TlsVersion
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import javax.net.ssl.SSLContext


object HttpClient {

    fun makeBuilder(url: String, client: OkHttpClient? = null, context: Context? = null): Retrofit.Builder {
        val builder = Retrofit.Builder()
            .addConverterFactory(GsonConverterFactory.create())
        if (url !== "")
            builder.baseUrl(url)
        else
            builder.baseUrl(Const.BASE_URL)

        if (client != null)
            builder.client(client)
        else {
            val client = OkHttpClient.Builder()

            val sc = SSLContext.getInstance("TLSv1.2")
            sc.init(null, null, null)
//            client.sslSocketFactory(Tls12SocketFactory(sc.socketFactory))

            val cs = ConnectionSpec.Builder(ConnectionSpec.MODERN_TLS)
                .tlsVersions(TlsVersion.TLS_1_2)
                .build()

            val specs = arrayListOf<ConnectionSpec>()
            specs.add(cs)
            specs.add(ConnectionSpec.COMPATIBLE_TLS)
            specs.add(ConnectionSpec.CLEARTEXT)

            client.connectionSpecs(specs)

            client.connectTimeout(30, TimeUnit.SECONDS); // connect timeout
            client.readTimeout(30, TimeUnit.SECONDS);    // socket timeout

            client.addInterceptor { chain ->
                if (context != null && !isOnline(context)){
                    if ((context.applicationContext as? MyApplication)?.getCurrentActivity() is ConnectionDelegate){
                        ((context.applicationContext as? MyApplication)?.getCurrentActivity())?.runOnUiThread {
                            ((context.applicationContext as? MyApplication)?.getCurrentActivity() as ConnectionDelegate)
                                .connectionDelegateShowNoConnection(code = 100)
                        }
                    }
                }
                val builderClient = chain.request().newBuilder()
                if (Const.getToken()?.length ?: 0 > 13) {
                    builderClient.addHeader("Authorization", Const.getToken())
                }
                builderClient.addHeader("Accept", "application/json")
                val newRequest = builderClient.build()

                val response = chain.proceed(newRequest)
                val code = response.code()

                if (context != null && code != 200)
                    ((context.applicationContext as? MyApplication)?.getCurrentActivity())?.runOnUiThread {
                        ((context.applicationContext as? MyApplication)?.getCurrentActivity() as? ConnectionDelegate)
                            ?.connectionDelegateShowNoConnection(code)
                    }
                response
            }
            builder.client(client.build())
        }

        return builder
    }

    inline fun <reified T> build(url: String = ""): T {
        return makeBuilder(url).build().create(T::class.java)
    }

    inline fun <reified T> buildRx(url: String = "",context: Context): T {
        val builder = makeBuilder(url,context=context)
            .addCallAdapterFactory(RxJava2CallAdapterFactory.createAsync())

        return builder.build().create(T::class.java)
    }
}