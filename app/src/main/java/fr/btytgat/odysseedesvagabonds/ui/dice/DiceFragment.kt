package fr.btytgat.odysseedesvagabonds.ui.dice

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import fr.btytgat.odysseedesvagabonds.databinding.FragmentDiceBinding

class DiceFragment : Fragment() {

    private lateinit var diceViewModel: DiceViewModel
    private var _binding: FragmentDiceBinding? = null

    // This property is only valid between onCreateView and
    // onDestroyView.
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        diceViewModel =
            ViewModelProvider(this).get(DiceViewModel::class.java)

        _binding = FragmentDiceBinding.inflate(inflater, container, false)
        val root: View = binding.root

        val textView: TextView = binding.textDice
        diceViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })
        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}