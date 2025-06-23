package uts.sdk.modules.utsXTranslateUtil
import io.dcloud.uts.console 

import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.TranslateLanguage


object NativeCode {
	fun getDownloadedModels(callback:(ArrayList<String>)->Unit){
		val modelManager = RemoteModelManager.getInstance()
		modelManager.getDownloadedModels(TranslateRemoteModel::class.java)
		    .addOnSuccessListener { models ->
				val stringList = ArrayList<String>()
		       for (item in models) {
				   stringList.add(item.getLanguage())
		       }
			   callback(stringList)
		    }
		    .addOnFailureListener {
				val stringList = ArrayList<String>()
				callback(stringList)
		    }
	}
}