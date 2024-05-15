

<img src="https://user-images.githubusercontent.com/83573296/120336791-fdbf9f00-c2f2-11eb-986b-5116dbe7bb71.png" align="right" alt="drawing" width="350"  >






# Welcome to Qbricks


Qbricks is open-source environment for automated formal verification of  quantum programs. It enables the writing of quantum circuit building programs, specified with their I/O functions and/or their resource requirements. Thanks to a characterization of quantum circuits as _paramatrized path-sums_, 
the specifications of Qbricks  circuit-building quantum programs reduces to first-order proof obligations. Its host language,  the [Why3](http://why3.lri.fr/) deductive verification environment, provides an interface with SMT-solvers, enabling an high-level of automation in the vertfication of Qbricks specifications.

So far, Qbricks framework enabled the verified implementation of several emblematic algorithm from the litterature, including the Deutsch-Jozsa algorithm, Quantum Phase Estimation (QPE), Grover search algorithm and Shor order finding (including an implementation of the oracle).

<img src = "https://www.cea.fr/PublishingImages/cea.jpg" align="left" alt="drawing" width="150">


<img src = "https://www.universite-paris-saclay.fr/sites/default/files/media/2019-12/logo-ups.svg" align="right" alt="drawing" width="150">

It is developed at the [CEA LIST](http://www-list.cea.fr/en/) [(part of Université Paris-Saclay)](https://www.universite-paris-saclay.fr/en) in collaboration with [Laboratoire Méthodes Formelles](https://lmf-paris-saclay.fr/newsite/)[(Université Paris-Saclay)](https://www.universite-paris-saclay.fr/en).


For an introduction to Qbricks, please read our [article](https://github.com/Qbricks/qbricks.github.io/files/6414263/final--ESOP-2021.pdf) and see the related presentation [slides](https://github.com/Qbricks/qbricks.github.io/files/6419798/main.pdf). A tutorial redaction is under progress.




![open_positions](https://user-images.githubusercontent.com/83573296/116979069-d1e5d500-acc4-11eb-9381-61a52f3e26f6.png)



### [3 years Postdoc position](https://github.com/Qbricks/qbricks.github.io/files/15310776/Fiche_de_poste_postdoc_qbricks.pdf)[](), CEA Paris-Saclay, France
Formal verification for quantum programming

**Keywords:** quantum programming, theory of programming langages, formal methods

The CEA List, Software Security Lab (LSL), has several open internship positions in the area of formal verification
for quantum programming , to begin as soon as possible at Paris-Saclay, France. The positions are 4-6 month long and can open the way to a doctoral work . They are articulated around the Qbricks tool, which aims at providing an automated solution for quantum programming formal verification. 

**Topic:** Quantum Programming and formal verification 

**Host:** Commissariat à l'Énergie Atomique, Software Security Laboratory

**Place:** Paris-Saclay, France

**Team:** Qbricks

**Advisor(s):** Christophe Chareton, Sébastien Bardin (first.name@cea.fr)

**Context.** 
Quantum hardware has made tremendous progress, and useful quantum machines are expected to become available in
a near future. Hence, the need to design and implement adequate software tooling for the quantum case, as available in
the classical computing case. Our long term goal is to design and develop formal techniques and tools enabling productive
and certified quantum programming. Especially, we develop Qbricks [1,2], a proof of concept environment for formally
verified quantum programming language.

**Current topics.** 
We consider the standard quantum hybrid model, where a classical program builds a quantum circuit
and sends it to a quantum co-processor. In these positions, we are interested in verification mechanisms aiming at ensuring
that a quantum program implementation indeed satisfies its intended behaviour. We propose the following topics:

• high-level automatic verification of quantum programs for implicit program properties,

• design of verification oriented hybrid quantum programming languages

• high-level functional reasoning for quantum programs,

• circuit-level automatic verification of quantum programs,

• verification of circuit transformation and compilation

More details on these possibilities topics will be happily provided! The list is not exhaustive, ask us if you have some
project in mind.

These positions include theoretical research as well as prototyping and experimental evaluation.The results will be
implemented and evaluated on QBricks, our young development and verification environment for quantum programs.

**Host Institution.** CEA is a leading institute in research in France and Europe. We are part of List, its 700 persons
institute dedicated to digital systems. Within List, the quantum verification group is a young and emerging six person
team, developping quantum static analysis/verified programming and debugguing solutions. CEA List is located in
Campus Paris Saclay.

**Requirements:** We welcome curious and enthusiastic candidates with a solid background in Computer Science,
both theoretical and practical, and a specialization in either formal methods or quantum computing (it is
assumed that candidates will dedicate some of their time upgrading their skills).

**Application:** Applicants should send an e-mail to Christophe Chareton (christophe.chareton@cea.fr ), including CV and motivation letter. 

**Deadline:** as soon as possible. Contact us for more information .

**References**

[1] Christophe Chareton and Sébastien Bardin and François Bobot and Valentin Perrelle and Benoît Valiron. An Automated Deductive Verification Framework for Circuit-building Quantum Programs Programming Languages and Systems - 30th European Symposium on Programming, ESOP 2021

[2] Christophe Chareton, Dongho Lee, Benoît Valiron, Renaud Vilmart, Sébastien Bardin, Zhaowei Xu:
Formal Methods for Quantum Algorithms. Handb. Formal Anal. Verification Cryptogr. 2023: 319-422

[3] Matthew Amy: Towards Large-scale Functional Verification of Universal Quantum Circuits. QPL 2018: 1-21

[4] Li Zhou, Gilles Barthe, Pierre-Yves Strub, Junyi Liu, Mingsheng Ying CoqQ: Foundational Verification of Quantum Programs. POPL 2023


# News 


- **Ongoing Postdoc** _October 2023_ Welcome, Nicolas Nalpon, working on certified compilation.
- **Ongoing PhD** _September 2023_ Welcome, Tomas Barros, working on formal verification and high-level programming.
- **Ongoing Postdoc** _June 2023_ Welcome, Nicolas Blanco, working on parametrized path-sums rewriting.
- **New relase** _March 2023_ Qbricks_1 is online! Available on main branch in [diffusion](https://github.com/Qbricks/qbricks.github.io), under License LGPL, 2.1. As main novelties the release provides:
  - LANGUAGE : new primitive constructs, containing (1) generic wiring and subcircuit control features (2) further gate constructors as primitives (Toffoli, Fredkin, X,Y,Z rotations, etc).
   - COMPILATION : a fully formally verified circuit transformation process, targetting Oqasm compatibile circuit, and an oqasm output generating function. Works for circuit without ancilla qbits. 
   - CASE STUDIES : new implementations of Shor algorithm, illutrating imperative QBricks styled programmation and the Oqasm extraction functionality.- **Our code is back** to open source [diffusion](https://github.com/Qbricks/qbricks.github.io), under License LGPL, 2.1,  _April 2022_ .
- **Ongoing internship** _April 2022_ Welcome, Mohamed Bassiouny, working on automated circuit equivalence verification.
- **Book chapter submission** _March 2022_ Our survey on formal methods in quantum computing was submitted, as a Book Chapter to appear in the " "Handbook of Formal Analysis and Verification in Cryptography" (CRC), see the [preprint](https://arxiv.org/abs/2109.06493).
- **Ongoing PhD** _March 2022_ Welcome, Jérôme Ricciardi, working on mixed path-sums.
- **Ongoing internship** _February 2022_ Welcome, Tomas Barros Carneiro, working on an imperative developement interface for quantum formal verification.
- **Presentation at IQFA** _Nov 2021_ Qbricks was presented at the [12th Colloquium on Quantum Engineering, Fundamental Aspects to Applications](https://iqfacolloq2021.sciencesconf.org/), 2021 [(slides)](https://github.com/Qbricks/qbricks.github.io/files/7526625/IQFA_21.pdf).
- **Online survey** [Formal Methods for Quantum Programs: A Survey](https://arxiv.org/abs/2109.06493) _September 2021_. 
- **Presentation at QPL** _June 2021_ Qbricks was presented at the 2021 online QPL conference [(slides)](https://github.com/Qbricks/qbricks.github.io/files/6630309/main.pdf).
- **Qbricks at ESOP**        _March 2021_  Glad to participate to the 2021 online ESOP conference [(slides)](https://github.com/Qbricks/qbricks.github.io/files/6419798/main.pdf).
-   **Paper accepted**        _December 2020_  Proud that our paper “An Automated Deductive Verification Framework for Circuit-building Quantum Programs” has been [accepted](https://github.com/Qbricks/qbricks.github.io/files/6414263/final--ESOP-2021.pdf) at ESOP’21.
- **Online preprint** _March, 2020_ Our preprint _Toward certified quantum programming_ is availeble on [Arxiv](https://arxiv.org/abs/2003.05841v1)
- **Talk at IWQC** _November, 2020_, with online [presentation](https://www.youtube.com/watch?v=HKlCr5ulTh0&ab_channel=CambridgeQuantumComputing)


# People

| Name      |     Position     |        Affiliation | Web site  |
| :------------ | :-------------: | :------------- |:------------- |
| Sébastien Bardin      |     Senior     |   [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) | [Sébastien Bardin](http://sebastien.bardin.free.fr/)|
| Benoît Valiron   |   Senior   |  [LMF](https://lmf-paris-saclay.fr/newsite/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) |[Benoît Valiron](https://www.monoidal.net/) |
| Christophe Chareton        |     Junior      |  [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) |[Christophe Chareton](https://sites.google.com/site/christophechareton/) |
| Nicolas Blanco        |     Postdoc      |  [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) | [Nicolas Blanco](https://nicolas-blanco.github.io/fr/)|
| Nicolas Nalpon        |     Postdoc      |  [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) | |
| Jérôme Ricciardi        |     PhD student      |  [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) | [Jérôme Ricciardi](https://www.researchgate.net/profile/Jerome_Ricciardi)|
| Tomas Barros Carneiro        |     PhD student      |  [CEA LIST](http://www-list.cea.fr/en/), [Université Paris-Saclay](https://www.universite-paris-saclay.fr/en) |[Tomas Barros Carneiro](https://github.com/tbc23)|

# Publications

## International conference

- [An Automated Deductive Verification Framework for Circuit-building Quantum Programs](https://github.com/Qbricks/qbricks.github.io/files/6414263/final--ESOP-2021.pdf), _March, 2021_ at ESOP’21.

## Book chapter

- [Formal Methods for Quantum Algorithsms](https://www.taylorfrancis.com/chapters/edit/10.1201/9781003090052-7/formal-methods-quantum-algorithms-christophe-chareton-dongho-lee-benoit-valiron-renault-vilmart-s%C3%A9bastien-bardin-zhaowei-xu), 09/2023. This chapter introduces both the requirements and challenges for an efficient use of formal methods in quantum computing and the current most promising research directions. While the recent progress in quantum hardware opens the door for significant speedup in cryptography as well as additional key areas (biology, chemistry, optimization, machine learning, etc), quantum algorithms are still hard to implement right, and the validation of quantum programs is a challenge. As an alternative strategy, formal methods are prone to play a decisive role in the emerging field of quantum software. The chapter also introduces several existing solutions for the formal verification of quantum compilation and the equivalence of quantum program runs. The vast majority of quantum algorithms are described within the context of the quantum co-processor model, i.e. an hybrid model where a classical computer controls a quantum co-processor holding a quantum memory.

## Preprint 


- [Toward certified quantum programming](https://github.com/Qbricks/qbricks.github.io/files/6415756/2003.05841v1.pdf), _March, 2020_

## Short articles

- A formally certified implementation of Shor algorithm quantum circuit, _IWQC, November 2020_ 
[video](https://www.youtube.com/watch?v=HKlCr5ulTh0&ab_channel=CambridgeQuantumComputing)
- [Qbricks, a framework for formal verification in quantum
computing](https://github.com/Qbricks/qbricks.github.io/files/6415909/Qbricks_Planqc.7.pdf)  _PlanQC, January 2020_ [video](https://www.youtube.com/watch?v=_6EhDf5IDuw&ab_channel=ACMSIGPLAN)
- [Toward_certified_quantum_programming_](https://github.com/Qbricks/qbricks.github.io/files/6415879/Toward_certified_quantum_programming_This_work_was_supported_by_the_French_National_Research_Agency__ANR___project_SoftQPro__ANR_17_CE25_0009.3.1.pdf)  _IWQC, November,2018_  (2nd International Workshop on Quantum Compilation).(link)
