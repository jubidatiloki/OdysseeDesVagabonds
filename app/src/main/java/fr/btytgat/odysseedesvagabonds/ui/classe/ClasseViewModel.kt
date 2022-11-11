package fr.btytgat.odysseedesvagabonds.ui.classe

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class ClasseViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "TODO: affichage des classes"
    }
    val text: LiveData<String> = _text
}