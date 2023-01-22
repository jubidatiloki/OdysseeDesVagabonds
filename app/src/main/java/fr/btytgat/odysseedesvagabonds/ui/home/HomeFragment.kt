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
import fr.btytgat.odysseedesvagabonds.database.entities.Classe
import fr.btytgat.odysseedesvagabonds.databinding.FragmentHomeBinding

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

        database = Firebase.database("https://odysseedesvagabonds-default-rtdb.europe-west1.firebasedatabase.app").reference

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


        val newClasse = Classe()

        val key = database.push().key
        database.child("Classe").child(key!!).setValue(newClasse)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}