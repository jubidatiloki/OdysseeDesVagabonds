package fr.btytgat.odysseedesvagabonds.ui.home

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class HomeViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "TODO: affichage du menu avec des squareButton des différents écrans"
    }
    val text: LiveData<String> = _text
}