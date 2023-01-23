package fr.btytgat.odysseedesvagabonds.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.google.android.material.snackbar.Snackbar
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import fr.btytgat.odysseedesvagabonds.databinding.FragmentHomeBinding
import fr.btytgat.odysseedesvagabonds.utils.DatabaseUtils

class HomeFragment : Fragment() {

    private lateinit var homeViewModel: HomeViewModel
    private var _binding: FragmentHomeBinding? = null
    private lateinit var database: DatabaseReference


    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        homeViewModel =
            ViewModelProvider(this).get(HomeViewModel::class.java)

        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        val root: View = binding.root

        val textView: TextView = binding.textHome
        homeViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })

        binding.fab.setOnClickListener { view ->
            Snackbar.make(view, "TODO: création de personnage", Snackbar.LENGTH_LONG)
                .setAction("Action", null).show()
        }
        return root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        updateDataFields()

        binding.btReset.setOnClickListener {
            DatabaseUtils.initDatabase()
            updateDataFields()
        }

        binding.btUpdateData.setOnClickListener {
            updateDataFields()
        }
    }

    fun updateDataFields(){
        val nb_max_classe = 12
        val nb_max_race = 8
        val nb_max_voie = 8 + 11 * 4 + 7
        val nb_max_rang = nb_max_voie * 5

        with(DatabaseUtils){
            database.child(KEY_CLASSES).get().addOnSuccessListener {
                binding.tvClasse.setText("nb classes: \n${it.childrenCount} / $nb_max_classe")
            }
            database.child(KEY_RACES).get().addOnSuccessListener {
                binding.tvRace.setText("nb races: \n${it.childrenCount} / $nb_max_race")
            }
            database.child(KEY_VOIES).get().addOnSuccessListener {
                binding.tvVoie.setText("nb voies: \n${it.childrenCount} / $nb_max_voie")
            }
            database.child(KEY_RANGS).get().addOnSuccessListener {
                binding.tvRang.setText("nb rangs: \n${it.childrenCount} / $nb_max_rang")
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}