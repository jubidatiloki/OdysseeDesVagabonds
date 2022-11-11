package fr.btytgat.odysseedesvagabonds.ui.dice

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class DiceViewModel : ViewModel() {

    private val _text = MutableLiveData<String>().apply {
        value = "TODO: lancer de dé avec param + historique des lancers"
    }
    val text: LiveData<String> = _text
}