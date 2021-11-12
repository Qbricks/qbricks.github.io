

<img src="https://user-images.githubusercontent.com/83573296/120336791-fdbf9f00-c2f2-11eb-986b-5116dbe7bb71.png" align="right" alt="drawing" width="350"  >

# Welcome to Qbricks


Qbricks is open-source environment for automated formal verification of  quantum programs. It enables the writing of quantum circuit building programs, specified with their I/O functions and/or their resource requirements. Thanks to a characterization of quantum circuits as _paramatrized path-sums_, 
the specifications of Qbricks  circuit-building quantum programs reduces to first-order proof obligations. Its host language,  the [Why3](http://why3.lri.fr/) deductive verification environment, provides an interface with SMT-solvers, enabling an high-level of automation in the vertfication of Qbricks specifications.

So far, Qbricks framework enabled the verified implementation of several emblematic algorithm from the litterature, including the Deutsch-Jozsa algorithm, Quantum Phase Estimation (QPE), Grover search algorithm and Shor order finding (including an implementation of the oracle).


It is developed at the [CEA LIST](http://www-list.cea.fr/en/) [(part of Université Paris-Saclay)](https://www.universite-paris-saclay.fr/en) in collaboration with [Laboratoire Méthodes Formelles](https://lmf-paris-saclay.fr/newsite/)[(Université Paris-Saclay)](https://www.universite-paris-saclay.fr/en).


For an introduction to Qbricks, please read our [article](https://github.com/Qbricks/qbricks.github.io/files/6414263/final--ESOP-2021.pdf) and see the related presentation [slides](https://github.com/Qbricks/qbricks.github.io/files/6419798/main.pdf). A tutorial redaction is under progress.



![open_positions](https://user-images.githubusercontent.com/83573296/116979069-d1e5d500-acc4-11eb-9381-61a52f3e26f6.png)

### PhD open positions (3 years): Probing quantum verification in the NISQ era

The goal of this doctoral position is to probe formal verification against first generation of quantum application (NISQ era). Possibilities include, among other: extending Qbricks semantic and proof model to the hybrid paradigm, develop and implement a specification and proof system for error propagation and correction in quantum computing, develop  certified ready-to-use NISQ applications.  

Keywords: quantum programming,  formal verification, NISQ, quantum error correction

### PostDoc open position (2 years) : verified compilation 

The goal of this post-doctoral position is to extend  formal verification practice to quantum compilation.  Possibilities include, among others, error correction mechanisms in certified quantum code, together with specifications and reasoning technique for certifying its reliability, automatized certified optimizer for quantum circuits, hardware agnostic assembly language together with its compiler,

Keywords: quantum programming, compilation, optimization, formal verification

### How to apply

Applications should be sent to sebastien.bardin@cea.fr as soon as possible (first come, first served) and by early July 2021 at the latest. Candidates should send a CV, a cover letter, a transcript of all their university results, as well as contact information of two references. Each  position is expected to start in October 2021.

Advisors: Sébastien Bardin (CEA), Christophe Chareton (CEA)
Contact: sebastien.bardin@cea.fr


# News 

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

# Publications

## International conference

- [An Automated Deductive Verification Framework for Circuit-building Quantum Programs](https://github.com/Qbricks/qbricks.github.io/files/6414263/final--ESOP-2021.pdf), _March, 2021_ at ESOP’21.

## Survey
- [Formal Methods for Quantum Programs: A Survey](https://arxiv.org/abs/2109.06493), 09/2021. Due to the destructive aspect of quantum measurement, formal methods are prone to play a decisive role in the emerging field of quantum software. In this survey, we present the challenges adressed to formal verificatio at every stage of the quantum  development process: high-level program design, implementation, compilation, etc. and we introduce  the current  most promising research directions

## Preprint 


- [Toward certified quantum programming](https://github.com/Qbricks/qbricks.github.io/files/6415756/2003.05841v1.pdf), _March, 2020_

## Short articles

- A formally certified implementation of Shor algorithm quantum circuit, _IWQC, November 2020_ 
[video](https://www.youtube.com/watch?v=HKlCr5ulTh0&ab_channel=CambridgeQuantumComputing)
- [Qbricks, a framework for formal verification in quantum
computing](https://github.com/Qbricks/qbricks.github.io/files/6415909/Qbricks_Planqc.7.pdf)  _PlanQC, January 2020_ [video](https://www.youtube.com/watch?v=_6EhDf5IDuw&ab_channel=ACMSIGPLAN)
- [Toward_certified_quantum_programming_](https://github.com/Qbricks/qbricks.github.io/files/6415879/Toward_certified_quantum_programming_This_work_was_supported_by_the_French_National_Research_Agency__ANR___project_SoftQPro__ANR_17_CE25_0009.3.1.pdf)  _IWQC, November,2018_  (2nd International Workshop on Quantum Compilation).(link)
