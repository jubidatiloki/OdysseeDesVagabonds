package fr.btytgat.odysseedesvagabonds.ui.character.view

import android.os.Bundle
import fr.btytgat.odysseedesvagabonds.R
import fr.btytgat.odysseedesvagabonds.ui.base.view.BaseActivity
import fr.btytgat.odysseedesvagabonds.ui.character.ICharacterView
import fr.btytgat.odysseedesvagabonds.ui.character.presenter.CharacterPresenter

class CharacterActivity: BaseActivity(), ICharacterView.IActivity {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_character)

        presenter = CharacterPresenter(this, this)
        presenter.onViewCreated()
    }


}