package fr.btytgat.odysseedesvagabonds.ui.character

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class CharacterViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "TODO: affichage du dernier personnage édité"
    }
    val text: LiveData<String> = _text
}