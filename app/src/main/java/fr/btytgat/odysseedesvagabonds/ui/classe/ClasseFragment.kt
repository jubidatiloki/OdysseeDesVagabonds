package fr.btytgat.odysseedesvagabonds.ui.classe

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import fr.btytgat.odysseedesvagabonds.databinding.FragmentClasseBinding

class ClasseFragment : Fragment() {

    private lateinit var classeViewModel: ClasseViewModel
    private var _binding: FragmentClasseBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        classeViewModel =
            ViewModelProvider(this).get(ClasseViewModel::class.java)

        _binding = FragmentClasseBinding.inflate(inflater, container, false)
        val root: View = binding.root

        val textView: TextView = binding.textGallery
        classeViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })
        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}