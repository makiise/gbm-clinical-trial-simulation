#set document(
  title: "Computational Framework for GBM Immunotherapy Simulation",
  author: "Mariami Garuchava",
)

#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
)

#set text(font: "New Computer Modern", size: 12pt, lang: "en")
#set heading(numbering: "1.1")


#set par(justify: true, leading: 1em)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1em)
  text(size: 16pt, weight: "bold", it)
  v(0.5em)
}

#show heading.where(level: 2): it => {
  v(0.6em)
  text(size: 13pt, weight: "bold", it)
  v(0.3em)
}

#show heading.where(level: 3): it => {
  v(0.4em)
  text(size: 12pt, weight: "bold", style: "italic", it)
  v(0.2em)
}



#page(numbering: none)[
  #align(center)[
    #v(3cm)

    
    #text(size: 16pt, weight: "bold")[
      Computational Framework for Clinical Trial Simulation
    ]

    #v(0.6em)

    
    #text(size: 14pt, style: "italic")[
      Survival Analysis and ODE-Based Modelling for GBM Immunotherapy
    ]

    #v(2.5cm)

    
    #text(size: 12pt)[Mariami Garuchava]

    #v(0.4em)

    
    #text(size: 12pt)[Student ID: 01317059219]

    #v(2cm)

    
    #text(size: 12pt)[
      Degree: Bachelor of Science \
      Program: Computer Science \
      University: Kutaisi International University
    ]

    #v(1.5cm)

    #text(size: 12pt)[Supervisor: Nino Demetrashvili]

    #v(1.5cm)

    #text(size: 12pt)[Date: June 2026]
  ]
]


// PAGE NUMBERING STARTS FROM HERE 
#set page(numbering: "1")
#counter(page).update(1)


//  ABSTRACT
#heading(level: 1, numbering: none)[Abstract]

This research demonstrates that in silico trials are a valuable and efficient way to optimize complex immunotherapy schedules before moving to human testing. Glioblastoma (GBM) is the most aggressive primary brain cancer, with a median survival of only 12 to 15 months despite standard surgery, radiotherapy, and chemotherapy. While immunotherapy holds promise, it has largely failed as a monotherapy in clinical trials, which motivates the study of combination regimens. Because real clinical trials are expensive, slow, and risky, this thesis presents a three-layer computational framework for in silico clinical trial simulation as a tool for early evaluation of treatment strategies.
The system is based on the tumor-immune ODE model, which describes the interactions between glioma cells, activated T cells, and myeloid-derived suppressor cells (MDSCs) under two drug controls: anti-PD-1 and a CCR2 antagonist. The framework consists of a deterministic ODE core; a stochastic layer that generates a virtual-patient cohort of 1,000 individuals using log-normal Monte Carlo sampling to account for biological variety; and an analysis layer that produces Kaplan-Meier survival curves, log-rank tests, and Cox hazard ratios. To make the trial more realistic, the simulation includes responder heterogeneity and patient censoring. Benchmarked three numerical solvers - RK45, LSODA, and Radau are also presented to find the most efficient choice for large-scale simulations.
The results from the 1,000-patient cohort show that combination therapy is the most effective treatment arm, followed by anti-PD-1 monotherapy and then the CCR2 antagonist. Combination therapy roughly halved the progression risk compared to no treatment $(text("Hazard Ratio") = 0.52, p < 10^(-28))$. Regarding computational performance, LSODA was the fastest solver, performing approximately twenty times faster than Radau because it can automatically switch strategies to handle the "stiffness" of the biological equations.

#v(1em)
*Keywords:* glioblastoma, ODE modelling, Monte Carlo simulation,
Kaplan-Meier, immunotherapy, scientific computing, RK45


//TABLE OF CONTENTS
#pagebreak()
#outline(title: "Table of Contents", depth: 3, indent: 1em)

#pagebreak()



= Introduction

This thesis presents a 3-layered software system designed to solve an ODE system based on human parameters through Monte Carlo sampling. The system provides numerical solutions to identify the most effective treatment among four distinct arms for patients diagnosed with Glioblastoma, while simultaneously focusing on the progression-free survival (PFS) endpoint. Furthermore, it evaluates and identifies the most efficient numerical solver necessary for the high-speed sampling of a large virtual population. The figure below illustrates the core architectural design of the entire project.


#figure(
  image("framework_figure_top.png", width: 140%)
)



#figure(
  image("framework_figure_bottom.png", width: 140%)
)

*Background and Motivation*

Glioblastoma (GBM) is the most common and aggressive primary brain cancer, characterized by a highly complex and immunosuppressed tumor microenvironment @anderson_2024a_global_stability @anderson_2024b_optimal_control. Despite medical intervention, the median survival remains between 12 to 15 months, with a five-year survival rate of less than 10%. The current standard of care, known as the Stupp protocol - consisting of surgery, radiotherapy, and temozolomide (TMZ) - has remained largely unchanged since its establishment in 2005. While immunotherapy drugs exist, they have largely failed as monotherapies in Phase III clinical trials for GBM due to the tumor's advanced survival strategies. Because real-world clinical trials are expensive, slow, and risky, there is a critical need for alternative methods to evaluate new treatments. A viable solution lies in the computational simulation of clinical trials, which allows for the testing of various treatment arms and scenarios within a virtual environment.

\

*Problem Statement*

The primary research problem is: How can ODE-based models combined with Monte Carlo simulation be used to effectively simulate GBM immunotherapy clinical trials and predict patient outcomes? This approach seeks to bridge the gap between theoretical mathematical models and clinical application by creating a "numerical stochastic process" that mimics real-world patient variability.

\

*Research Questions*


*Can the ODE system correctly model GBM-immune dynamics?* The study investigates if the system accurately represents the interactions between glioma cells, T cells, and MDSCs.

*Which ODE solver is most efficient for repeated Monte Carlo runs?* This involves benchmarking different numerical methods, such as RK45, LSODA, and Radau, to determine which is best suited for large-scale simulations.

*What does virtual patient simulation reveal about combination immunotherapy?* The research examines if pairing treatments like anti-PD-1 and CCR2 antagonists provides a significant survival advantage over monotherapy.

\


*Objectives*

The thesis aims to achieve the following four specific objectives:

*Implement the ODE system:* Encode the mathematical equations representing glioma cells, activated T cells, and myeloid-derived suppressor cells (MDSCs).

*Numerical methods comparison:* Evaluate and compare the computational efficiency of different mathematical solvers for the ODE system.

*Monte Carlo virtual patients: *Generate a realistic virtual cohort by randomly sampling biological parameters from established distributions.

*Kaplan-Meier survival analysis:* Calculate survival statistics and visualize outcomes to compare the efficacy of different treatment arms.

\

*Thesis Structure*

The thesis is organized into several chapters to systematically address the research problem.

Chapter 2 explains human biology and the characteristics of the Glioblastoma.

 Chapter 3 provides the mathematical background, covering ordinary differential equations, numerical methods, Monte Carlo sampling techniques, and the principles of survival analysis. 
 
 Chapter 4 presents the GBM model, detailing the source papers, biological assumptions, state variables, and parameter distributions used in the study.
 
  Chapter 5 describes the implementation, outlining the three-layer software architecture - the ODE layer, the Monte Carlo cohort generation layer, and the analysis layer.
  
   Chapter 6 details the results, including the virtual patient distributions, simulated tumor-immune dynamics, survival outcomes for the different treatment arms, and solver efficiency benchmarks.
   
    Finally, Chapter 7 provides the conclusion, summarizing the main findings and suggesting directions for future research.



= Biological background
== Glioblastoma
Glioblastoma (GBM) is the most common and aggressive primary brain cancer. It is known as a highly malignant tumor that comprises primary brain malignancies.
It creates a highly complex and
immunosuppressed tumor microenvironment, which makes
it exceptionally difficult to treat @anderson_2024a_global_stability @anderson_2024b_optimal_control.
Regarding its epidemiology, approximately 350,000 people are newly diagnosed with brain tumors globally each year, resulting in roughly 250,000 deaths. Most patients can not survive from the tumor within 12 to 15 months of diagnosis, even with medical intervention. Within five years of diagnosis, the survival rate is less than 10%. The standard of care @anderson_2024b_optimal_control, known as the Stupp protocol, consists of surgical resection followed by radiotherapy and chemotherapy with temozolomide (TMZ). This protocol has remained the primary treatment strategy since it was established in 2005.
Despite aggressive treatment, recurrence is essentially universal @anderson_2024a_global_stability @anderson_2024b_optimal_control. Even when the tumor is significantly reduced, patients are highly likely to relapse regardless of how close they come to a “disease-free” condition.

The motivation to move toward immunotherapy stems from the minimally effective results of older standard treatments and the need for new strategies @anderson_2024a_global_stability. Immunotherapy is considered to be a good treatment strategy because its goal is to harness the immune system to overcome the tumor’s defenses. While single-agent treatments like anti-PD-1 have failed as monotherapy in Phase III clinical trials, combination immunotherapies - such as pairing immune checkpoint inhibitors with therapeutics that target immunosuppressive myeloid-derived suppressor cells (MDSCs) - are being explored to increase the cytotoxic immune response and improve long-term survival outcomes @anderson_2024a_global_stability @anderson_2024b_optimal_control.
The biological mechanisms underlying this immunotherapy approach - the PD-L1/PD-1 immune checkpoint, MDSC-mediated suppression, and the reasons why combination therapy outperforms monotherapy - are explained in detail in Sections 2.4 through 2.6.
== The Blood-Brain Barrier
The blood-brain barrier (BBB) @anderson_2024b_optimal_control is a specialized system of microvascular endothelial cells that serves as the interface between the central nervous system (CNS) and the peripheral blood circulation.
Anatomically, the BBB consists of endothelial cells joined by tight junctions, along with pericytes and astrocyte end-feet, which create a highly selective semipermeable barrier. It evolved to protect the CNS from toxins, pathogens, and fluctuations in blood chemistry, maintaining a stable environment for neural signaling. This same protective mechanism makes drug delivery exceptionally hard because the BBB prevents approximately most small-molecule drugs and nearly all large-molecule drugs (like the anti-PD-1) from entering the brain at therapeutic concentrations @anderson_2024b_optimal_control.
While the BBB is a formidable obstacle, in the context of GBM, it is often locally disrupted. This is referred to as the “leaky BBB”.
In a growing tumor, the rapid, chaotic growth of new blood vessels (angiogenesis) often results in “leaky” vessels that are structurally weaker than normal brain capillaries, allowing some therapeutics to penetrate the tumor core more easily than they would healthy brain tissue @anderson_2024a_global_stability @anderson_2024b_optimal_control.



== The Immune System and Cancer
The immune system’s primary role in oncology is to identify and destroy malignant cells to prevent tumor progression. However, aggressive cancers like glioblastoma (GBM) create a highly complex and immune-suppressed environment that prevents the immune system from functioning effectively. Modern research into immunotherapy seeks to harness and amplify the body’s natural immune defenses to overcome these barriers, though many monotherapies have failed because tumors develop advanced survival strategies @anderson_2024a_global_stability @anderson_2024b_optimal_control.


T cells are critical components of the adaptive immune response. In the study of GBM-immune dynamics, T cells are represented by all cells carrying the CD3+ marker, which includes both CD4+ helper T cells, which coordinate the immune response by releasing signaling molecules like cytokines to support other immune cells, and CD8+ cytotoxic T cells, often called “killer” T cells, the primary effectors that directly attack cancer cells.
In these models, activated T cells refer to those that have been stimulated either by the presence of a tumor or by cytokines like IL-12, resulting in their recruitment and influx to the tumor site to perform their defensive duties @anderson_2024a_global_stability @anderson_2024b_optimal_control.


Activated T cells are considered the main drivers of tumor cell death. When these T cells reach the glioma microenvironment and interact directly with malignant cells, they kill them at a specific biological rate @anderson_2024a_global_stability @anderson_2024b_optimal_control.


The tumor microenvironment is the local environment surrounding a tumor, consisting of cancer cells, immune cells, blood vessels, and signaling molecules. In the context of glioblastoma, the TME is notoriously immunosuppressive. Instead of being a site of active immune defense, the GBM microenvironment is often reprogrammed by the tumor to actively recruit cells that shield the cancer from T cell attacks and promote tumor progression through mechanisms like angiogenesis @anderson_2024a_global_stability @anderson_2024b_optimal_control.

Immune evasion is a general phenomenon where cancer cells develop the ability to mask themselves from recognition or actively downregulate the immune response. Cancers evade the immune system, effectively disguising the tumor cells and suppressing the cytotoxic response even when T cells are present. This evasion is often the primary reason why tumors continue to grow despite a patient having a technically functional immune system.
GBM evades the immune system through two specific mechanisms: PD-L1 and MDSCs, which are covered in the next two sections @anderson_2024a_global_stability @anderson_2024b_optimal_control.


The PD-L1 / PD-1 immune checkpoint is a prominent axis of immunosuppression that glioblastoma (GBM) cells use to defend the immune system from attacking healthy cells. T cells have an " off switch, " which means the PD-1 (programmed cell death protein 1) receptor is an inhibitory receptor located on the surface of activated T cells, and when this switch is triggered, it sends signals to the T cell to stop attacking healthy cells. GBM cells produce a protein called PD-L1. When the tumor’s PD-L1 connects with the T cell’s PD-1 receptor, the tumor is being masked, making it invisible to the immune system. This interaction is the one that allows the tumor to grow, because it turns off the T cells that are supposed to kill the cancer.
Drugs called anti-PD-1 are designed to block this interaction. By binding to the PD-1 receptor, the drug prevents the tumor’s PD-L1 from connecting, which unmasks the tumor and lets the T cells do their job again.
While these drugs work well for other cancers, they often fail when used alone (monotherapy) in GBM because these drugs only work if there are enough activated T cells already near the tumor to start an attack, but GBM often keeps T cell numbers very low, and, also, GBM uses other methods to hide, specifically MDSCs (myeloid-derived suppressor cells), which continue to shut down T cells even if the PD-1 “off switch” is blocked. Those are the main reasons why monotherapy fails @anderson_2024a_global_stability @anderson_2024b_optimal_control.


The CCR2 pathway is one of the primary ways glioblastoma (GBM) protects itself from the immune system. It involves a signaling loop where the tumor sends out chemokines to bring in myeloid-derived suppressor cells (MDSCs). By blocking this specific pathway, the influx of these cells might be stopped, and that will allow the immune system to attack the tumor more effectively. *MDSCs (myeloid-derived suppressor cells) *are immature cells from the bone marrow. In a healthy body, these myeloid cells would eventually turn into regular immune cells. However, in the presence of cancer, they remain in an immature state and are “reprogrammed” to become highly suppressive. Instead of helping the body, they act as a shield for the tumor, shutting down the T cells that are trying to kill the cancer @anderson_2024a_global_stability @anderson_2024b_optimal_control.

GBM recruits CCL2/CCL7 chemokines.
The recruitment process consists of three main steps. It starts with chemokine release: GBM cells produce and secrete signaling proteins called chemokines, specifically CCL2 and CCL7.
Then these chemokines act as a beacon for any cell carrying a CCR2 receptor.
And, after that, MDSCs express the CCR2 receptor on their surface, and when they detect the CCL2/CCL7 “scent,” they travel from the bone marrow directly into the tumor microenvironment. CCR2 antagonists are drugs (such as CCX872 or BMS-813160) that bind to the receptor first, and by doing so, they prevent the tumor’s chemokines from connecting, which keeps the MDSCs from ever reaching the brain @anderson_2024a_global_stability @anderson_2024b_optimal_control.

== Combination Immunotherapy
In the context of glioblastoma (GBM), combination immunotherapy refers to the concurrent use of two different types of treatments to overcome the tumor’s complex defenses. This specific research focuses on pairing anti-PD-1, an immune checkpoint inhibitor, with a CCR2 antagonist, which targets immunosuppressive cells. The goal is to maximize the body’s natural immune response by removing multiple biological “brakes” (PD-1) at once. Previous chapters (2.4 & 2.5) describe why only using anti-PD-1 or CCR2 alone fails. However, combining these two therapies creates synergy because they target the two primary “axes” of GBM immunosuppression simultaneously. The CCR2 antagonist reduces MDSC levels, which indirectly increases the number of activated T cells available to fight the tumor, and once these T cell numbers are bolstered, the anti-PD-1 drug can more effectively “unmask” the tumor, allowing the larger number of T cells to recognize and destroy the malignant cells.
The experimental evidence and biological synergy justify why clinical simulations and preclinical studies use four distinct treatment arms:
No Treatment (Control),
Anti-PD-1 Monotherapy,
CCR2 Antagonist Monotherapy,
Combination Therapy

@anderson_2024a_global_stability @anderson_2024b_optimal_control.




#set math.equation(numbering: "(1)")
= Mathematical Background <math>


For clinical trial simulation, the computational framework is built using a 3-layer architecture consisting of: 
  *The ODE system*,
  *Monte Carlo Simulation*, and
  *Survival Analysis*.

This chapter explores all three layers in order to understand the core mechanisms underlying clinical trial simulations.

  == Ordinary Differential equations

  Let $f$ be a continuously differentiable function, a so-called "smooth" function. An _ordinary differential equation_ (ODE)
  has the following form:


  $
x' = f(t, x, lambda)
$ <ode>



   Where the prime denotes differentiation with respect to the independent variable $t$ (usually a measure of time).
   the dependent variable $x$ is a _vector of
state variables_, and $lambda$ is a _vector of parameters_. 

The equation

$ m (d^2 x) / (d t^2) + b (d x) / (d t) + k x = 0 $ <eq-damped>

is an *ordinary differential equation*, because it involves only ordinary
derivatives $(d x) / (d t)$ and $(d^2 x) / (d t^2)$. That is, there is only
one independent variable, the time $t$.
\
 In contrast, the heat equation
$ (partial u) / (partial t) = (partial^2 u) / (partial x^2) $
is a *partial differential equation* — it has both time $t$ and space $x$
as independent variables. 

=== State Variables and Parameters
State variables are a set of variables needed to fully describe a mathematical state of the dynamic system.
$x$ is a vector which is composed of all state variables.
@tab-1 shows appropriate state variables for the GBM model, which are elaborated in the following chapters.

$lambda$ is a vector composed of constants, and it is used to define the system’s behavior. Parameters remain fixed during each simulation. They describe different kinds of physical or biological properties.
The list of parameters used for the GBM model, their descriptions, and units are shown in @tab-params-def, and summary statistics are shown in @tab-params-vals.

Later chapters also discuss how the parameters were chosen during simulation.

=== Order of an equation

The highest-order derivative with respect to the independent variable determines the order of the equation. The GBM model consists only of first-order equations, since only first-order derivatives appear.
(#ref(<eq-glioma>, supplement: none))
(#ref(<eq-tcells>, supplement: none))
(#ref(<eq-mdsc>, supplement: none))


=== Initial Value Problem (IVP)
The GBM model discussed in this paper uses differential equations to describe the evolution of state variables for a physical process. From the initial value of the state variable, its future values need to be determined.
The mathematical model is then defined by a pair of equations:


$ x' = f(t, x, lambda), quad quad x(t_0) = x_0 $

The second equation is called an _initial condition_ and
the pair of equations is called an *_initial value problem_*.
Respectively, a solution is a function $x(t)$ that satisfies both the differential equation and the initial condition.

=== Linear and Nonlinear systems


A framework for ordinary differential equations is provided
by the following form of system

$ x' &= f_1(x_1, dots, x_n) \
  & dots.v \
  x'_n &= f_n(x_1, dots, x_n) $ <eq-system>



This system is said to be *linear*, if all the $x_i$ on the
right-hand side have degree one. Otherwise, the system
is *nonlinear*. 


=== Importance of numerical solution for ODE system
Nonlinearity makes differential equation systems very difficult and most of the time, impossible, to solve
analytically. The reason behind this is simple:
The most important difference is that linear systems are easy to break down into several parts, solve them
separately and recombine them in the end to get the answer. This simplifies the solving process of complex problems and forms the basis of some famous methods, such as Laplace transforms, superposition arguments,
and Fourier analysis. However, the principle of superposition fails for nonlinear systems, and that’s where the numerical solution is needed.

== Numerical Foundations and Runge-Kutta Methods
Before moving to the numerical implementation part, I first introduce and provide a brief explanation of some of numerical methods, starting from the simplest one.

*Euler's method* is the simplest numerical method for approximating the solution of an ODE.
Given the _differential equation_
$dot(x) = f(x)$ with _initial condition_
$x = x_0$ at $t = t_0$. Obviously, the goal is to find a systematic way to approximate the
solution $x(t)$. Starting from $x_0$, the local velocity is $f(x_0)$.
Over a short time, denoted as $Delta t$, the phase point moves approximately
$f(x_0) Delta t$, which would only be an exact if the velocity is constant, a good
approximation is achieved for small enough $Delta t$. This gives a new position
$x_1 = x_0 + f(x_0) Delta t$. Iterating, the update rule becomes:

$x_(n+1) = x_n + f(x_n)Delta t $.
Euler's method can be improved since it estimates the derivative only at the left end of the time interval between $t_n$ and $t_(n+1)$. A better approach would be to use the average derivative between across this interval. That is *_improved Euler's method_*. While easy to implement, Euler's method requires a massive number of steps for high precision.



*Local truncation error (LTE)* defines a measure of the precision of the mathematical approximation used for a single step; basically, it is the difference between the true solution and the numerical solution after one iteration.
 *Global
error* describes the difference between the true solution and the numerical solution at any given point.




Higher-order methods do not automatically mean that they are superior, because they require more calculations and function evaluations, which makes them computationally expensive.


*_Fourth-order Runge-Kutta (RK4) method_* tends to nicely balance computational efficiency and high accuracy. This method is a bit different from the actual one used in this paper. RK4 uses a fixed step size to solve ODE’s. For a step size $Delta t$, the update rule is:

with the four stage values defined as:

$ bold(k)_1 &= bold(f)(bold(x)_n) Delta t \
  bold(k)_2 &= bold(f)(bold(x)_n + 1/2 bold(k)_1) Delta t \
  bold(k)_3 &= bold(f)(bold(x)_n + 1/2 bold(k)_2) Delta t \
  bold(k)_4 &= bold(f)(bold(x)_n + bold(k)_3) Delta t $

#align(right)[@strogatz]



The reason why RK4 is called fourth-order method is that it has local truncation error $cal(O)(Delta t^5)$ and global
error $cal(O)(Delta t^4)$.
A fixed step size of $Delta t = 0.1$ typically provides sufficient accuracy
for smooth low-dimensional dynamical systems.

See @strogatz and @chicone for better understanding this chapter.



In this paper, the ODE system is solved by the numerical method named the Dormand & Prince method, but before actually discussing the implementation steps, we need to  go through the historical development and mathematical analysis of higher-order Runge-Kutta (RK) numerical methods.

The primary goal of embedded Runge-Kutta formulas is to provide an efficient way to perform automatic step size control.
Rather than using Richardson extrapolation, which requires computing two small steps and one large step to estimate error, embedded formulas construct two numerical approximations - $y_1 $ (order p) and $y_2$
(order $hat(p)$) that share the same function evaluations ($k_i$).



The method uses a single scheme of coefficients ($c_i$, $a_(i j)$) to compute a set of stages. These same stages are then combined using two different sets of weights ($b_i$, $hat(b)_i$) to produce a lower-order solution ($y_1$) and a higher-order solution ($hat(y)_1$).



#figure(
  $ mat(
    delim: #none,
    augment: #(hline: (5, 6), vline: 1, stroke: 0.5pt),
    0, , , , ;
    c_2, a_(2 1), , , ;
    c_3, a_(3 1), a_(3 2), , ;
    dots.v, dots.v, dots.v, dots.down, ;
    c_s, a_(s 1), a_(s 2), dots, a_(s\,s-1);
    , b_1, b_2, dots, b_s;
    , hat(b)_1, hat(b)_2, dots, hat(b)_s
  ) $,
  caption: [Butcher tableau of an embedded Runge-Kutta method.
    By using a single scheme of coefficients ($c_i$, $a_(i j)$), the stages $k_1, dots, k_s$ are computed. Because these stages are shared, the two different numerical approximations ($y_1$ and $hat(y)_1$) are produced using the same function evaluations.
    @hairer1993[Eq. (4.6)].],
    
) <fig-embedded-tableau>




The lower-order approximation with an order of $p$ is

$ y_1 = y_0 + h (b_1 k_1 + dots + b_s k_s) $ <eq-y-low>

and the higher-order approximation with an order of $hat(p)$ is

$ hat(y)_1 = y_0 + h (hat(b)_1 k_
1 + dots + hat(b)_s k_s). $ <eq-y-high>


*Estimate of the local truncation error* is provided by the difference between these two results ($y_1$ - $hat(y)_1$). Using the same function evaluations ($k_i$) for both approximations makes code more flexible and less computationally expensive


*Fehlberg’s embedded methods* were developed in the 1960s, and his idea was to minimize the error coefficients of the lower-order result ($y_1$) in order to make his methods optimal.

The lower (4th) order approximation is intended to be used as an initial value for the next step, while the 5th-order result serves only as the error estimator.
The lower-order approximation was intended to be used as an initial value for the next step.

In order to make his methods optimal, Fehlberg tried to minimize the error coefficients for the lower-order result ($y_1$) by using the _standard integration_, which means that it uses the lower (4th) order approximation and continues using it during integration, while the 5th-order result serves only as the error estimator.


  *The local extrapolation* is different from the standard one; it continues integration using the higher-order result ($hat(y)_1$) and chooses the step size by the difference between the two results.

Since Fehlberg uses the standard integration, it increases the accuracy of the 4th-order solution.

Its disadvantage is that it fails selecting step size, because Fehlberg definitely optimized $y_1$ and it someimes becomes almost as accurate as $hat(y)_1$ and that can lead to substantially smaller estimated error than the true error (E = $y_1 - hat(y)_1$) because $y_1$ and $hat(y)_1$ are too close to each other.


=== Dormand & Prince method (RK45)
*RK45* is also an embedded Runge-Kutta pair of orders 5 and 4. Its numerical efficiency and special design distinguishes from the Fehlberg method. This method is used to solve the GBM ODE system described in this paper.

Unlike *Fehlberg’s method*, which optimizes the lower-order solution, *Dormand & Prince* uses local extrapolation to advance integration using the higher (5th) order approximation.

Below, in the table, there are specially derived coefficients shown that are used to minimize the error coefficients of the 5th-order result.

#figure(
  table(
    columns: 8,
    align: center + horizon,
    stroke: none,
    inset: 6pt,

    // Vertical line separating c column from A matrix
    table.vline(x: 1, stroke: 0.5pt),

    // Horizontal line between stage rows and weight rows
    table.hline(y: 7, stroke: 0.5pt),

    // ─── Stage rows: c | A ────────────────────────────────
    $0$,       [], [], [], [], [], [], [],
    $1/5$,     $1/5$, [], [], [], [], [], [],
    $3/10$,    $3/40$, $9/40$, [], [], [], [], [],
    $4/5$,     $44/45$, $-56/15$, $32/9$, [], [], [], [],
    $8/9$,     $19372/6561$, $-25360/2187$, $64448/6561$, $-212/729$, [], [], [],
    $1$,       $9017/3168$, $-355/33$, $46732/5247$, $49/176$, $-5103/18656$, [], [],
    $1$,       $35/384$, $0$, $500/1113$, $125/192$, $-2187/6784$, $11/84$, [],

    // ─── Weight rows: b (y_1) and b-hat (ŷ_1) ─────────────
    $y_1$,        $35/384$, $0$, $500/1113$, $125/192$, $-2187/6784$, $11/84$, $0$,
    $hat(y)_1$,   $5179/57600$, $0$, $7571/16695$, $393/640$, $-92097/339200$, $187/2100$, $1/40$,
  ),
  caption: [Butcher tableau of the Dormand–Prince 5(4) method (DOPRI5).
  In here, there are seven stage evaluations: $k_1, dots, k_7$, which are defined by column $c$ and matrix $A$.
  Down below, there are two weight rows producing  a fifth-order solution
    ($y_1$) which is used to determine a step size by local extrapolation, and a
    fourth-order solution ($hat(y)_1$) only needed to estimate the error.
    Source: @hairer1993[Table 5.2].],
) <fig-dopri5-tableau>


*First Same As Last (FSAL)* property is a key innovation of the RK45 method. As shown above, Dormand & Prince have seven stage evaluations, and the 7th stage is identical to the 1st stage ($k_1$) of the subsequent step. This obviously reduces computational cost, because the method only needs to evaluate six functions per step instead of seven.

In this chapter, the main beneficial points of an embedded Runge-Kutta method - Dormand & Prince were discussed.

Summary of these key points is shown below on the @dopri5.

#figure(
  table(
    columns: (auto, auto),
    align: (center, left),
    stroke: 0.5pt,
    table.header(
      [*RK45 (DOPRI5)*], [*Pros*],
    ),
     [Higher precision], [The coefficients are determined in a way that this method is significantly more precise than RKF45, Which implies a better numerical performance.],
    [computationally efficient], [FSAL property decreases computational cost],
    [Local Extrapolation], [Advances integration using the higher (5th) order approximation which guarantees efficiency],
    [dense output], [provides precise approximations and graphical output at any point between steps without additional function evaluations], 
  ),
  caption: [Key advantages of Dormand & Prince method],
) <dopri5>


// aqedan grammarlym dafixa

If you need further details and proofs for the methods provided in this chapter, see @hairer1993.

=== RADAU & LSODA numerical solvers
In implementation, two other numerical solvers are used too with RK45 to compare their efficiency.
*LSODA* @misra_2022_bz_reaction (Livermore Solver for Ordinary Differential Equations, with Automatic Method Switching)  is a high-precision numerical solver designed to solve systems of ODEs. Its defining feature is its ability to automatically choose between different integration methods based on the state of the system. By monitoring data in real-time, it can decide whether a problem is stiff or non-stiff and uses different methods for these two cases. See @misra_2022_bz_reaction for more information about LSODA numerical solver.

*RADAU* @chen_2024_pinn_radau refers to a class of implicit Runge-Kutta methods used for the numerical solution of differential equations. It has high-precision method with excellent numerical stability. See @chen_2024_pinn_radau for further details of RADAU.

A *non-stiff system* is one where all variables change at a similar pace, allowing the solver to take large steps easily. A *stiff system* occurs when some biological processes happen much faster than others. This forces simple solvers to take tiny, time-consuming steps to avoid 'crashing' or becoming unstable, which is why specialized solvers like Radau or LSODA are necessary to handle those fast-changing dynamics efficiently.





== Monte Carlo simulation

The Monte Carlo method uses random sampling to solve mathematical problems. 



=== History of Monte Carlo



The first experiment, which used random sampling to find a solution for a mathematical problem, was documented in 1977 by a French mathematician, Comte de Buffon. He was trying to calculate the probability that a thrown needle onto a horizontal plane would have an intersection with aligned straight lines on that plane. 





If length of the needle is  *$L$* , and the straight lines are distanced by *$d$* , where $d > L$ , then the probability *P* that randomly thrown needle will intersact with one of these lines is given by this formula:



*$ P = (2L)/(pi d) $*



Buffon derived this formula by performing an experiment of throwing a needle onto the plane many times.



That method was not used as a general computational tool for centuries, but some scientists found it captivating. For instance, Laplace advanced Buffon's experiment by using a grid instead of just straight lines. Then, Lord Kelvin used random sampling for kinetic theory. He was randomly drawing papers with numbers on them from a bowl. In the 1930s, while Enrico Fermi was working on the behavior of the newly discovered neutron, he used random sampling experiments to understand how neutrons interact with matter.



The formal name was given in the 1940s by scientists who were working on nuclear weapons at Los Alamos. One of the scientists, Stanislaw Ulam, saw the potential of that method while he was playing solitaire (a game where you arrange cards into specific groups), and trying to estimate the chance of winning the game by simulating the playing many times, he thought that was the easiest solution, and that led him to use that tool in nuclear physics. In 1949, he and Nicholas Metropolis first described the Monte Carlo method in their published article in _Journal of the American Statistical Association_. See @metropolis1949.

 For more historical background of Monte Carlo, see @kalos2008.



Formally, Monte Carlo is a technique for solving a mathematical problem.

through random sampling, when an analytical calculation gets too complex.

The Monte Carlo method is *stochastic* because it relies on random sampling. In stochastic processes, each state is determined by random events. By Monte Carlo, we can find the solution of non-probabilistic problems using probabilistic methods, and simulation is the direct transcription of a natural random process. The development of digital computers has significantly increased the efficiency of Monte Carlo methods, since it is much easier to run simulations on a computer rather than just perform the experiment in real life.



=== main use cases of Monte Carlo

The two primary use cases for the Monte Carlo method involve its application as a numerical tool for solving mathematical problems and as a direct model for complex, real-world random processes.





For clinical trial, we are basically *simulating stochastic systems*, meaning, we use Monte Carlo to mimic a system which has random behaviour.

A stochastic process is defined as a sequence of states where the evolution from one state to the next is determined by random events. When we perform a clinical trial simulation using Monte Carlo methods, we are creating a "numerical stochastic process" on a computer to mimic real-world variability.



*Key aspects of why clinical trial simulations are considered stochastic:*

*_Modeling Random Events:_* Clinical trials are often modeled as sequences of random events, For instance, the provided GBM model in this paper has clinical endpoint which estimates time from treatment initiation until disease starts to progress - Progression-Free Survival (PFS). That uncertainty is modeled by random numbers.





*_Discrete Event Simulation:_* This specific type of Monte Carlo approach is used to test systems that inherit stochastic behaviour. It generates artificial random events to see how a system, like a clinical trial, performs under different conditions.





*_Handling Medical Data:_* In medicine, simulation is used to model realistic scenarios that traditional analytical math struggles to solve easily, such as survival times for patients or comparing the success rates of different treatments. 





*_Realistic Distributions:_* Older - "standard" models used simplified, often non-realistic distributions. Stochastic simulations have the ability to use more complex and realistic models that better represent the actual variability found in human health data.



=== The Law of Large Numbers (LLN)



The Monte Carlo method works because it transforms non-probabilistic problems, such as multidimensional integrals, into a stochastic structure that can be solved through random sampling, and the Law of Large Numbers (LLN) provides the mathematical justification for why Monte Carlo provides a valid numerical estimate.



The Law of Large Numbers states that if you take a sequence of independent and identically distributed random variables $X_1, X_2, ... , X_n$ , their sample mean $overline(X)_n$ 

  will converge to the true population mean $mu$ as the number of samples $ n$ approaches infinity. That means, the more times we perform an experiment, the average result will go closer and closer to the true expected value.





=== The Central Limit Theorem 

The Central Limit Theorem is used to place confidence intervals around Monte Carlo estimates, which means it provides a precise way to measure how reliable the simulation results are. While the Law of Large Numbers guarantees that an estimate will eventually converge to the true value, the *Central Limit Theorem* is used to describe the distribution of the error that occurs during that process.



*_The Central Limit Theorem_* states that the distribution of a Monte Carlo estimator will behave as a normal distribution for a large enough sample size $(N)$. To be able to apply Central Limit Theorem, the original distribution needs to provide a *finite variance*.

 If the variance is infinite (like the Cauchy distribution, which is a special case known as having undefined variance), the limit distribution will not be normal, meaning that this method can not be used to calculate standard confidence intervals.

 Although even if the finite variance exists, the method will only guarantee highly accurate results as $N arrow infinity$, because if the sample size $N$ is too small, the central limit theorem might derive optimistic confidence intervals @kalos2008.



  === Convergence rate

  Because of the LLN, as the sample size N increases, the variance of the mean value decreases at a rate of $1/N$. This means the probability of a large deviation between the Monte Carlo estimate and the true value becomes very small as more trials are conducted. While the variance decreases as $1/N$, the statistical/standard error is

defined as the square root of the variance, it shrinks as $1/sqrt(N)$.

See @kalos2008.



=== Sampling from distributions



Sampling is the core of the Monte Carlo method, and its capability is to produce a sequence of random variables that follow a specific probability distribution function.

=== Pseudorandom number generation (PRNG)

 All computational Monte Carlo sampling fundamentally starts with uniform random variables on the interval (0,1), which are generated by a computer as *pseudorandom numbers* because all other distributions require a sequence of uniform variables to be simulated. See @robert2004.







Pseudorandom number generation produces sequences of numbers that mimic the statistical properties of truly independent and identically distributed random variables. However, because these sequences start from an initial value - *seed*, they are not truly random but are reproducible, meaning, if the same seed is used all the time, the same sequence of numbers will be generated See @robert2004, @kalos2008.





*Mersenne Twister* is modern algorithm to generate uniform random variables. It features a period of $2^19937

 −1$, ensuring that the sequence does not repeat even during the most extensive computational simulations. It can generate sequences that maintain statistical randomness across a very high number of dimensions because of a 623-dimensionally equidistributed generator.

  Like other deterministic algorithms, it starts from an initial value - a seed. Using a fixed seed enables replaying an exact simulation, which is critical for debugging and regulatory validation in fields like clinical trials. Those are the reasons why the Mersenne Twister still remains the default.

pseudorandom number generator in MATLAB, R, and Python's standard library. 



Implementation based on that paper for the GBM system uses more recent algorithm *Permuted Congruential Generator* (PCG-64) @oneill2014, it is the default in NumPy's modern `default_rng` (recommended function that initializes a random number generator) API @harris2020.

Like the Mersenne Twister, PCG-64 is deterministic and seeded.



=== Pseudorandom number generator (PRNG) in clinical trials



In the context of clinical trials, a pseudorandom number generator (PRNG) is an essential tool used for the construction of stochastic models that represent the inherent variability and uncertainty found in patients.

populations. Some of its benefits are the following: *_virtual patient cohorts can be generated_* by drawing human characteristics from specific distributions, ensuring that virtual patients exhibit realistic interindividual variability. Since clinical trials are stochastic systems, PRNG can be used for *_modeling Stochastic event_*, it mimics natural random process within trials. By performing many Monte Carlo simulations, different scenarios can be tested, that *_optimizes trial design and power_*. Simulations are useful for *_handling non-standard scenarios_* - If a trial is expected to violate traditional statistical assumptions, such as the Proportional Hazard Assumption (the ratio of the risks between the two groups remains constant over time), which is common in cancer immunotherapy trials where survival benefits may be delayed. For more precise information about this section, see @bedding2014 and @kalos2008.



=== The log-normal distribution

The log-normal distribution is considered to be the optimal choice for modeling parameters in clinical and statistical simulations because its range is strictly restricted to positive values $(0, infinity)$. A log-normal variable $Y$ is produced by taking the exponential of $X$, where $X$ is a normal variable: *$Y = e^X$*. Since the exponential of any real number is always non-negative, that guarantees the positivity of the parameters, which is a necessary requirement for biological parameters @robert2004.



=== Application of log-normal distribution in clinical trials

Another benefit of using a log-normal distribution for patient health data is that it can *handle Skewness*. Human health data often exhibits a “right-skewed” behavior where most observations are clustered at lower values, but a few “long-tail” observations exist at very high values. The log-normal distribution naturally captures this skewness, making it a more faithful representation of real patient data than a symmetric Normal distribution. See more on @robert2004 @kalos2008.





== Survival Analysis     





Survival analysis is a specialized branch of statistics used to analyze *time-to-event data*, which measures the duration of time until a specific event occurs. In clinical oncology, the event is often *overall survival* (OS), which defines the time from treatment until a patient’s death, or the clinical endpoint of the GBM model presented in this paper - *Progression-Free Survival (PFS)*, which measures the time before the tumor starts to grow again.


   === Time-to-event data and censoring <censoring>



In a simulation, the *"Event time"* is determined by the “disease trajectory” of a virtual patient. For instance, if the model simulates tumor growing until it reaches a pre-defined point (when the tumor can not grow more than it is during that time of simulation), the “death” event occurs, and that elapsed time is “Event time”.

*Time-to-event data* is a specific statistical data type consisting of the event times and censoring status recorded across the entire virtual cohort. See @creemers2023.


*The censoring* is the primary characteristic that makes 

Time-to-event data is unique and different from standard statistical methods. It might occur when a patient’s actual event time can no longer be recorded because the study ended @robert2004.

In such cases, it is only known that the survival time was greater than the duration of the observation.

The standard way to represent censored data models is: * $(T_i, δ_i)$* where $T_i$ is observed time and  $δ_i$  - a binary indicator. $T_i$ can be derived from the following formula: $T_i = min {Y_i, overline(u)}$ where $Y_i$ is the event time and $overline(u)$ is the duration of the study. The binary indicator stores the information if the event was actually observed $(δ_i = 1)$ or if the observation was censored $(δ_i = 0)$.


Traditional analytical math struggles to accurately process such cases without specialized survival analysis models @robert2004 @creemers2023.

   === The Kaplan-Meier estimator



   One specific model is the Kaplan-Meier estimator, which visualizes survival curves from time-to-event data while, at the same time, is able to handle censoring @creemers2023. It is the standard method for visualizing survival outcomes in clinical research or major cancer immunotherapy trials @creemers2023. The Kaplan-Meier provides a non-parametric estimate of survival probability for some time intervals, meaning it shows the actual patterns of survival, even if they are unusual, and the estimator calculates the probability of surviving for each time interval (for instance, every month). By multiplying these probabilities together, it builds a survival curve that drops whenever an event (like a death) occurs @creemers2023 @robert2004.



   === The log-rank test



The log-rank test is used as a fundamental statistical tool in survival analysis. It compares the time-to-event data between two or more treatment groups, known as arms @creemers2023. The primary use of the log-rank test in clinical research is to determine if there is a statistically significant difference between the survival distributions of different cohorts.

The log-rank test is also used for determining the efficacy of various dose regimens, such as comparing a treatment arm, which might be immunotherapy, against a control arm, like an arm where patients are on a placebo or are receiving a standard of care @creemers2023.

*Null Hypothesis* ($H_0$)  states that there is no difference between the survival distributions of the cohorts being compared. This implies that the hazard ratio (see precise definition in the following subsection) is equal to 1, meaning the risk that the event occurs is the same in all treatment arms. *Alternative Hypothesis* ($H_1$) asserts that the survival distributions differ statistically from each other. In that case, the hazard ratio is not equal to 1, indicating that one treatment regimen provides a survival advantage/disadvantage over the other. In clinical trial simulations, the test produces a *p-value*. The trial is considered to be a “positive” if $p < 0.05$, which represents the Significance Threshold @creemers2023.


The log-rank test handles censoring properly because it does not rely on knowing the final event time for every patient. Instead, it performs comparisons based on risk sets at each discrete event time. Clinical trial data used in simulations include risk tables, which record the number of patients that are considered to be “at risk” of an event at various time points.

*Comparative mechanism* of the test is following: At every time an event occurs, the test compares the number of observed events in a treatment group to the number expected if the null hypothesis were true. Because it only considers patients who have neither had the event nor been censored yet at that specific moment, it incorporates the information from censored patients for exactly as long as they were observed @creemers2023 @robert2004. When the virtual cohort is partitioned into multiple arms, the log-rank test compares the survival distributions across these arms simultaneously, detecting whether

They differ significantly. See more about survival analysis in @klein2003. The four arms defined for the GBM model and corresponding survival analysis are described in the implementation chapter.









   === Hazard ratios



   A hazard ratio (HR) is a statistical measure that indicates the difference in risk of an event (like a death) between two treatment groups over time. It is derived from the hazard function, which represents the instantaneous event rate at a specific time t, given that the subject has survived up to that point @klein2003.

The hazard ratio between a treatment arm (A) and a reference arm (B) is defined as:

*$ H R = (lambda_A (t))/(lambda_B (t))$* and it  provides a direct comparison of risk. If

$H R = 1$, that is the indicator of the equivalent risk, meaning there is no observed difference in the hazard rates between the two arms.

$H R < 1$ indicates reduced risk in the treatment arm relative to the reference, while

$H R > 1 $ implies elevated risk in the treatment arm @klein2003.




   === Median survival time 

The median survival time is a fundamental summary measure in survival analysis, defined as the shortest time at which the survival function is $<= 0.5$. It represents the time when it is expected that half of the cohort has experienced the event. The method for determining the median survival time depends on the type of data and the statistical model being used.

From a Kaplan-Meier curve ($hat(S)(t)$), the median is the time at which the estimated survival probability drops to or below 0.5. This method is used for the GBM model, which is described in the implementation chapter.

The median is often preferred over the mean survival time for several reasons. As mentioned earlier, human survival data is usually highly skewed, with a few long-term survivors creating a “long tail”. The median provides a more representative “center” for such data than the mean and guarantees robustness to skewness. The median can also handle censoring effectively because calculating the mean requires conditions that do not always meet the clinical trial properties. Since computing the mean requires the survival curve to drop to zero (the entire virtual population experiences a death event), which rarely happens in clinical trials, if the curve does not reach zero due to censoring, the mean can only be “restricted” to a specific time window, whereas the median can still be calculated as long as the curve drops below 0.5 @klein2003.

In clinical trials, particularly for cancer immunotherapy, median survival is a critical endpoint for comparing treatment arms. For the defined GBM model in this paper, the primary clinical endpoint is the median PFS for every four arms, which is computed from the corresponding Kaplan-Meier estimate. The following chapter also describes all these implementation details.

If you need further details and proofs for the methods provided in this chapter, see @hairer1993.





= The GBM model
In this chapter, the GBM model is presented which is a combination of biology (chapter 2) and mathematics (chapter 3).


== Source papers and modeling strategy 

The mathematical model used in this simulation is derived from the work of Anderson et al. (2024a) @anderson_2024a_global_stability and Anderson et al. (2024b) @anderson_2024b_optimal_control. Anderson et al. (2024a), published in the Journal of Mathematical Biology, establishes the underlying baseline dynamics and the original tumor-immune ODE system for *glioma cells (C*) (see @eq-glioma), *activated T cells (T)* (see @eq-tcells), and *myeloid-derived suppressor cells (M)* (see @eq-mdsc). This foundational study also provides the parameter distributions (See @tab-params-def & @tab-params-vals). The model is further developed in Anderson et al. (2024b) @anderson_2024b_optimal_control, published in the Journal of Theoretical Biology, which extends the system by adding the drug control terms *$u_1$*
​(representing anti-PD-1) and *$u_2$*
​(CCR2 antagonist). While the 2024a paper provides the core biological framework, the drug-control equations used for optimizing treatment regimens are described in the 2024b paper.


== Model assumptions and simplifications 
The mathematical model for glioblastoma (GBM) dynamics is built upon several assumptions and simplifications to ensure practical identifiability and computational feasibility.

*Spatial homogeneity*: The model is a system of ordinary differential equations (ODEs), which assumes that all cell populations are well-mixed and lacks any spatial structure. Relaxing this assumption would require using partial differential equations (PDEs) or agent-based models to track cell migration, spatial gradients of chemokines, and localized tumor architecture.

*BBB handled implicitly*: The blood-brain barrier (BBB) is not modeled as a separate compartment. Instead, its restrictive filtering effect is absorbed directly into the constant drug control variables ($u_1$ and $u_2$), which represent the net therapeutic strength that successfully reaches the tumor microenvironment. Relaxing this assumption would necessitate a multi-compartment system to explicitly model the pharmacokinetic transport of therapeutics across endothelial tight junctions into the central nervous system.

Murine calibration: The model parameters are fit to preclinical experimental data from mouse models (KR158 glioma cells), meaning the biological rates may not perfectly reflect human oncology. Relaxing this would require re-estimating parameters like tumor growth rates and immune kill rates using human clinical trial data to account for different biological timescales.

*Single sub-population per cell type*: The system assumes that all glioma cells share a single set of parameters, ignoring the clonal heterogeneity typically found in aggressive brain cancers. Relaxing this would require additional equations to represent distinct tumor clones, such as those that are treatment-resistant or have different growth dynamics.

Constant doses: This simulation scope simplifies the time-varying optimal control paths ( $u_1(t), u_2(t)$) described in the Anderson papers into fixed dosages for the treatment arms. Relaxing this would involve implementing the continuous administration schedules determined by optimization software to find the most efficient drug delivery paths.


== State variables 

The following state variables represent the core biological populations in the glioblastoma-immune dynamics model.
#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (center, left, center),
    stroke: 0.5pt,
    table.header(
      [*State variables*], [*Biological meaning*], [*Units*],
    ),
    [$C(t)$], [Number of glioma (tumor) cells], [cells],
    [$T(t)$], [Number of activated T cells (CD3+, includes CD4+ and CD8+)], [cells],
    [$M(t)$], [Number of MDSCs (myeloid-derived suppressor cells)], [cells],
  ),
  caption: [State variables of the GBM tumor-immune ODE model
    (Anderson et al., 2024a).],
) <tab-1> 

== The glioma equation 
Based on the model developed in Anderson et al. (2024b), the differential equation representing the rate of change for glioma cells is:

$ (d C) / (d t) = underbrace(lambda_C C (1 - C / C_("max")), "logistic growth") - underbrace(eta T C, "killed by T cells") $ <eq-glioma>\

The first term represents the *logistic growth* of the malignancy, where $lambda_c$
  is defined as the intrinsic tumor cell growth rate. This parameter dictates how aggressively the cancer cells multiply over time when resources are abundant. This growth rate is a primary driver of tumor burden, and its interaction with other biological parameters determines the overall progression of the disease.

  The variable $C_max$ represents *the carrying capacity* of the tumor cells, serving as the biological “ceiling” for the population within the brain. It represents the maximum number of cells the environment can support based on physical space and nutrient availability. It is important to note that $C_max$ is a mathematical limit of the tumor’s size and is not the same as the experimental humane endpoint.
  The second term represents the mass-action *killing of tumor cells by activated T cells*. This model assumes that the destruction of cancer cells is dependent on the direct interaction between the effector T cell population (T) and the glioma cell population $C$. As T cells and tumor cells increase, the frequency of these encounters rises, leading to a higher overall rate of tumor cell death.
The parameter *$eta$* is the specific *kill rate *of tumor cells by T cells. It quantifies the efficiency of the body’s natural defense mechanism, representing the speed at which an individual activated T cell can identify and eliminate a malignant cell. Mathematical analysis suggests that for a patient to reach a “tumor-free” state, this immune-mediated kill rate must be potent enough to overcome the tumor’s intrinsic growth rate ($lambda_c$) and the various forms of immunosuppression present in the microenvironment
@anderson_2024a_global_stability @anderson_2024b_optimal_control.

== The T cell equation 
This differential equation representing the rate of change for activated T cells $(T)$ is:

$ (d T) / (d t) &= (underbrace(a_T, "activation") + underbrace(s_T T C, "stimulation")) dot underbrace(1 / (1 + rho (T + epsilon_C C)(1 - u_1(t)) T), "inhibition by PD-1-PD-L1") \
              & quad - underbrace(r T M, "inhibition by MDSCs") - underbrace(d_T T, "death") $ <eq-tcells>
              \


The numerator *$a_T + s_T T C$ * describes the two primary ways activated $T$ cells enter or increase within the tumor microenvironment. The parameter $a_T$ represents a constant homeostatic production or activation rate, occurring independently of the tumor’s presence, often attributed to baseline immune signaling from cytokines like IL-12. This is combined with the  $s_T T C$ term, which represents tumor-driven stimulation. This models how the presence of glioma cells actively recruits more $T$ cells and stimulates their proliferation directly at the tumor site.

The denominator *$1 / (1 + rho (T + epsilon_C C)(1 - u_1(t)) T)$*  represents the PD-L1/PD-1 immune checkpoint inhibition, a mechanism of immune evasion where the tumor “exhausts” or turns off incoming $T$ cells. The variable $u_1 (t)$ serves as the anti-PD-1 control variable, representing the percentage of this inhibitory “off switch” that is blocked by the drug. The factor *$(1−u_1) $* mathematically weakens the inhibition in the model; as the drug efficacy reaches 100% $(u_1 = 1)$, the inhibitory term in the denominator vanishes, allowing the T cell population to expand without these biological “brakes”.

The term $r T M$ models the suppression of T cells by myeloid-derived suppressor cells (MDSCs). The parameter $r$ represents the specific suppression rate, quantifying how effectively the MDSC “bodyguards” can deactivate the cytotoxic immune response to protect the malignancy.

The final term, − $d_T T$, accounts for the natural death of $T$ cells at a constant rate $d_T$. This term ensures the model remains biologically realistic by acknowledging that immune cells have a finite lifespan and will eventually succumb to natural apoptosis regardless of tumor interactions. In a healthy, tumor-free state, the steady-state level of the immune system is determined by the balance between this natural death rate and the baseline activation rate $a_T$
@anderson_2024a_global_stability @anderson_2024b_optimal_control.

== The MDSC equation

Based on the model developed in Anderson et al. (2024b), the differential equation representing the rate of change for myeloid-derived suppressor cells (M) is:
 
$ (d M) / (d t) = underbrace(s_M C (1 - u_2), "stimulation by chemokines") - underbrace(d_M M, "death") $ <eq-mdsc>

The first term - $s_M C (1 - u_2)$ represents the recruitment of MDSCs to the tumor microenvironment in response to signaling proteins (chemokines) secreted by the malignancy. Specifically, glioma cells produce CCL2 and CCL7, which act as a beacon for MDSCs carrying the CCR2 receptor. The recruitment rate is proportional to the number of tumor cells ©, as a larger tumor burden produces a higher concentration of chemokines. The variable $u_2$ serves as the CCR2 antagonist control, representing the percent reduction of this recruitment rate by the drug. By including the factor $(1−u_2)$,the model simulates how the therapeutic blocks CCR2 receptors to scale down the influx of these cells; a theoretical value of $u_2 = 1$ would represent a complete blockade where no new MDSCs can reach the brain.

While the original optimal control framework in Anderson et al. (2024b) @anderson_2024b_optimal_control utilizes time-varying functions $u_2(t)$ to determine mathematically ideal treatment schedules, this thesis simplifies the drug controls $u_1$ and $u_2$ to fixed constant values (e.g., 0.7) for the duration of the trial. This means the immunotherapy is at a constant therapeutic strength throughout the entire simulation. The primary aim of this research is not to determine an optimal dosing schedule, but rather to evaluate how different treatment arms compare in survival outcomes across a virtual cohort. For this comparison, a fixed representative dose per arm is the appropriate tool.

The final term, $d_M M$, accounts for the natural death of MDSCs at a constant rate $d_M$. This term ensures that the MDSC population remains biologically realistic by acknowledging that these cells have a finite lifespan. In these simulations, that internal clearance rate (d_M) is a critical parameter; subjects with higher natural MDSC death rates are more likely to achieve long-term survival, as their bodies can more effectively clear the immunosuppressive cells that protect the tumor.

== Drug control variables u₁ and u₂
The variable $u_1$ represents the percent reduction of the PD-L1-PD-1 inhibition rate $(rho)$ by the administration of an anti-PD-1 immune checkpoint inhibitor. Biologically, this control simulates the drug binding to the PD-1 receptors on activated T cells, which prevents them from being “turned off” by the tumor’s PD-L1 markers. By reducing this inhibition, the therapy effectively “unmasks” the malignancy and allows for a more robust cytotoxic immune response.

The variable $(u_2)$
represents the percent reduction of the MDSC recruitment rate $(s_M)$ by a CCR2 antagonist. This control simulates the therapeutic blocking of CCR2 receptors on myeloid-derived suppressor cells, which prevents them from detecting the CCL2 and CCL7 chemokines secreted by the tumor. By stopping these  cells from ever reaching the brain, the drug reduces the overall immunosuppressive shield protecting the tumor.

Both control variables are bounded within the interval $[0,1]$ to remain biologically and numerically consistent.
$u_i = 0$ (No Drug) : This limit case represents a state where no treatment is administered, and the biological processes of immune inhibition or MDSC recruitment occur at their full, natural rates.
$u_i = 1$ (Perfect Blockade): This represents a theoretical “perfect” treatment where the target mechanism is 100% blocked. Because a perfect blockade is physiologically unrealistic, these simulations utilize a maximum effective value (such as 0.7 as implemented in code) to represent a more plausible therapeutic limit.

While the original Anderson papers utilize time-varying Lebesgue integrable functions $(u_i (t))$ to find optimal treatment paths, this paper treats these controls as constants as a primary modeling simplification (as noted in §3.2). Mathematically, the $u_1$ variable enters multiplicatively as the factor $(1 − u_1)$ inside the inhibition term of the T-cell denominator. This effectively relaxes the PD-L1/PD-1 checkpoint, allowing the T-cell population to expand more freely as the drug concentration increases. In the MDSC Equation, the variable $u_2$ enters multiplicatively as the factor $(1 − u_2)$ within the recruitment term $(s M ⋅C)$. This directly reduces the recruitment of new MDSCs from the bone marrow to the tumor site based on the efficacy of the antagonist.


== Parameters 
The model parameters were primarily established using the Approximate Bayesian Computation (ABC) rejection method as detailed in Anderson et al. (2024a) @anderson_2024a_global_stability and Anderson et al. (2024b) @anderson_2024b_optimal_control. This computational approach produced posterior probability distributions for the biological rates by sampling one million parameter sets and accepting those that closely matched murine experimental data. Summary statistics for these parameters, including the best fit, mean, median, mode, and standard deviation, are provided for the glioma, T cell, and MDSC populations. While the source material often utilizes "Best Fit" values for representative subject simulations, this thesis uses the *Mean as the cohort center* and the *SD as the spread* to define the parameter ranges for the virtual population. 




#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left + horizon, left + horizon, center + horizon),
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt } else if y == 1 { 0.6pt } else { 0pt },
      bottom: 0pt, left: 0pt, right: 0pt,
    ),
    inset: (x: 8pt, y: 6pt),
    table.header(
      [*Parameter*], [*Definition*], [*Units*],
    ),
    table.cell(colspan: 3, fill: luma(240), inset: (x: 8pt, y: 5pt))[*Glioma Cells ($C$)*],
    [$lambda_C$], [Tumor cell growth rate], [day#super[$-1$]],
    [$C_(max)$], [Carrying capacity of tumor cells], [cell],
    [$eta$], [Kill rate of tumor cells by T cells], [day#super[$-1$] cell#super[$-1$]],

    table.cell(colspan: 3, fill: luma(240), inset: (x: 8pt, y: 5pt))[*T Cells ($T$)*],
    [$a_T$], [T cell activation rate], [cell day#super[$-1$]],
    [$s_T$], [Rate of tumor cell-mediated proliferation of T cells], [day#super[$-1$] cell#super[$-1$]],
    [$rho$], [T cell inhibition rate by PD-L1-PD-1 complex formation], [cell#super[$-2$]],
    [$epsilon_C$], [Expression of PD-L1 in tumor cells vs. T cells], [—],
    [$r$], [T cell inhibition rate by MDSCs], [day#super[$-1$] cell#super[$-1$]],
    [$d_T$], [T cell death rate], [day#super[$-1$]],

    table.cell(colspan: 3, fill: luma(240), inset: (x: 8pt, y: 5pt))[*Myeloid-Derived Suppressor Cells ($M$)*],
    [$s_M$], [MDSC recruitment rate by tumor production of chemokines], [day#super[$-1$]],
    [$d_M$], [MDSC death rate], [day#super[$-1$]],

    table.hline(stroke: 0.8pt),
  ),
  caption: [Model parameters of the GBM–immune dynamics model: definitions and units.],
) <tab-params-def>


#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt } else if y == 1 { 0.6pt } else { 0pt },
      bottom: 0pt, left: 0pt, right: 0pt,
    ),
    inset: (x: 8pt, y: 6pt),
    table.header(
      [*Parameter*], [*Best Fit*], [*Mean*], [*Median*], [*Mode*], [*SD*],
    ),
    table.cell(colspan: 6, fill: luma(240), inset: (x: 8pt, y: 5pt))[*Glioma Cells ($C$)*],
    [$lambda_C$], [$0.431$], [$0.272$], [$0.250$], [$0.174$], [$0.114$],
    [$C_(max)$], [$3.04 times 10^6$], [$1.87 times 10^7$], [$1.45 times 10^7$], [$4.19 times 10^6$], [$1.48 times 10^7$],
    [$eta$], [$2.57 times 10^(-8)$], [$1.84 times 10^(-7)$], [$1.27 times 10^(-7)$], [$4.03 times 10^(-8)$], [$1.86 times 10^(-7)$],

    table.cell(colspan: 6, fill: luma(240), inset: (x: 8pt, y: 5pt))[*T Cells ($T$)*],
    [$a_T$], [$3.26 times 10^6$], [$2.48 times 10^6$], [$2.45 times 10^6$], [$1.98 times 10^6$], [$1.45 times 10^6$],
    [$s_T$], [$8.56 times 10^6$], [$5.73 times 10^6$], [$5.91 times 10^6$], [$8.79 times 10^6$], [$2.63 times 10^6$],
    [$rho$], [$0.107$], [$0.223$], [$0.207$], [$0.0768$], [$0.142$],
    [$epsilon_C$], [$16.2$], [$37.5$], [$31.1$], [$7.00$], [$29.3$],
    [$r$], [$6.92 times 10^(-6)$], [$2.85 times 10^(-5)$], [$1.83 times 10^(-5)$], [$3.60 times 10^(-6)$], [$2.76 times 10^(-5)$],
    [$d_T$], [$0.0221$], [$0.402$], [$0.415$], [$0.656$], [$0.213$],

    table.cell(colspan: 6, fill: luma(240), inset: (x: 8pt, y: 5pt))[*Myeloid-Derived Suppressor Cells ($M$)*],
    [$s_M$], [$0.0466$], [$0.0476$], [$0.0476$], [$0.0392$], [$0.0040$],
    [$d_M$], [$0.251$], [$0.258$], [$0.263$], [$0.419$], [$0.143$],

    table.hline(stroke: 0.8pt),
  ),
  caption: [Posterior statistics of GBM model parameters from ABC rejection method (Anderson et al., 2024). Summary statistics of $s_M$ re-estimated with the updated MDSC equation.],
) <tab-params-vals>

== Initial conditions
The following initial conditions are used for all simulations, as established in Anderson et al. (2024b):

*$C_0=35,000$ cells* Represents the initial orthotopic implantation of KR158 glioma cells into the murine brain.
*$T_0=100$ cells* Represents a small baseline population of activated T cells present at the tumor site at the start of the simulation.
*$M_0=0 $cells* Reflects the biological reality that myeloid-derived suppressor cells are absent from the brain prior to the tumor's secretion of recruitment chemokines. It is important to note that the value of $T_0=100$ is a modeling choice by the authors based on experimental data and is not the resting equilibrium $(T^∗) $ of the immune system.

== Resting T cell Equilibrium $T^*$ 
$T^*$  is defined as the steady state of the immune system in a tumor-free environment $(C=0)$. Under these conditions, the T cell population dynamics are formed by the equation $a_T / (1 + rho T^2) - d_T T = 0 $. Determining $T^∗$ requires solving a cubic root-finding problem, which this research performs numerically (as detailed in the Implementation chapter using the _brentq_ algorithm). For the mean parameter set, this equilibrium is approximately $T^∗ approx 302$ cells. Critically, $T^*$ is an analysis quantity used to characterize the baseline strength of the host's immune system and it is not used as an initial condition for the tumor-progression simulations.

== Progression Endpoint
The progression event in this simulation is defined as the point at which a subject’s tumor cell count reaches 75% of that specific patient's own carrying capacity $(C_max)$. This threshold is chosen as a progression proxy for the subsequent survival analysis. This choice is necessitated by the parameter regime identified in Anderson et al. (2024b) @anderson_2024b_optimal_control, while a theoretical humane endpoint of approximately $2×10^8$
  cells is often discussed, the estimated biological ceiling for glioblastoma in these models $(C_max approx 1.87×10^7 $ 
  cells) typically lies well below that value. Consequently, this thesis uses 75% of patient-specific $(C_max)$
  to provide a consistent and realistic measure of treatment failure and disease advancement.


= Implementation <ch5>
This chapter describes the software implementation of the GBM clinical-trial
simulation defined in Chapter 4. The framework has three layers where the first layer represents the ODE system described in the GBM model chapter,
the second layer generates a virtual-patient cohort via Monte Carlo,
and the third, analysis layer produces survival outcomes. This chapter describes the design of 
each layer, and the complete source code is provided
in @appendix-a.


== Software and Tools
The simulation is implemented in Python 3, which uses the following libraries: *NumPy, SciPy, lifelines, pandas, Matplotlib*.
It has a deterministic behaviour with a _random seed 42_.

== Layer 1 — ODE system

The first layer encodes the ODE system from Chapter 3 (@eq-glioma,
@eq-tcells @eq-mdsc) as a single Python function. Given the current populations of tumor cells, T cells,
and MDSCs, it returns their instantaneous rates of change. The function takes two drug
controls $u_1$ and $u_2$ as constant scalars, and the
11 model parameters (@tab-params-def). Since the goal of this thesis is just to compare treatments, and not to find the perfect dosing schedule, keeping drug strength fixed (at 0.7) is a reasonable design choice, and time-varying controls are left for future work.
Before the simulation starts, the resting T-cell state $T^*$ is computed. Because this fixed point is the root of a cubic equation, it cannot be written in a simple closed form, and is solved numerically. For the
mean parameter set, this yields $T^* approx 302$ cells. The initial condition for the simulations is $T_0 = 100$ cells.
The simulation runs last for up to 200 days for each patient. Progression is defined at the moment when the tumor grows to 75% of the patient’s maximum carrying capacity. To catch exactly when this happens, an “event function” is used, which is a built-in feature of the ODE solver. It is highly accurate and makes the code run faster because it stops calculating as soon as the limit is hit instead of just checking the tumor size every day or week, which would only give us an estimate.
If 200 days pass and the tumor never reaches that size, then the patient is recorded as a survivor of the trial without progression.

== Layer 2 — Creating the Virtual Patient Cohort

The basic model only represents one specific patient. To make it realistic, a cohort of virtual patients is needed. For this, Monte Carlo sampling is used, which basically means randomly generating different biological parameters for each person to match them with the natural differences in real glioblastoma patients.
For every virtual patient, 11 different biological parameters are generated randomly by using a log-normal distribution. That method only produces positive numbers, which is important since biological parameters can not be negative. These 11 values are generated independently, using the averages and spreads from @tab-params-vals.
Using just one single “best fit” number wouldn’t produce the variety, so that’s the reason why the “Mean” is taken as the center, and “SD” as the spread. To make the simulation clinically realistic, two more rules were added. First, 30% of our virtual patients are labeled as “non-responders,” meaning the drug barely works on them. This reflects the reality that immunotherapy does not work for everyone. Second, 15% of the patients were randomly made to leave the trial early, which marks them as “censored” (see @censoring for the definition).

One single group of 1000 virtual patients is generated, and all four different treatments are tested on this exact same group, so no new groups are created for each test. This results in non-random survivals because
any difference in survival is purely because of the drug itself. The entire cohort, consisting of 1000 patients going through 4 treatments, means the code runs 4000 separate simulations in total.


== Layer 3 — Analysis

The final step is turning raw data into actual results. For every virtual patient in every treatment group, the exact time when their tumor progressed, or if they dropped out early, is known. Now, survival statistics need to be calculated.

For each treatment, *Kaplan–Meier survival curve* is created. This is just the standard medical way to graph how many patients stay progression-free over time, and it can also automatically handle the “censored” patients, who dropped out. If more than half the people make it to the end of the trial without their tumor growing, the median survival time is reported as “not reached”.

To see if a drug actually worked better than no treatment, 
 The *log-rank test* and The *Cox proportional-hazards model* are run. The log-rank test can tell if the difference between these survival curves is random or actually real, while the Cox proportional-hazards model provides the information about how much the treatment lowered the risk of the tumor growing (a number below 1 means the drug helped).
 


== Reproducibility and outputs

When you run the main code, it goes through all three layers and saves everything to your computer. It generates the survival graphs, the raw data for every patient, and simple CSV tables with the final stats and numerical solver speeds.

A separate, smaller script is made just for drawing the graphs. This way, you can customize the appearance of the graph without running the entire heavy simulation again. A fixed “seed” for the random numbers makes the code reproducible. If you run it again, you will get the exact same patients and the exact same survival results. The only thing that changes is the millisecond timing of the solvers, since that depends on the hardware of the computer.

= Results

This chapter covers the results of the clinical trial simulation. Everything provided here comes from one single, reproducible run of the code (using seed 42).

== Virtual-patient cohort

To build our group of virtual patients, the code randomly picked 11 biological parameters for each person, using the log-normal distribution explained in @ch5. @fig-paramdist shows the numbers across the whole group. The graphs lean a bit to the right; that is just how log-normal distributions look. It highlights just how different real patients can be. For example, things like the tumor’s maximum capacity ($C_(“max”)$) and the immune system’s kill rate ($eta$) can vary hugely from person to person. Because of this realistic variety of parameters, the realistic spread of survival outcomes is produced.

#figure(
  image("fig_paramdist.png", width: 100%),
  caption: [Distributions of the 11 model parameters across the virtual 
    cohort. Each parameter is sampled from a log-normal distribution 
    matching the mean (red line) and standard deviation],
) <fig-paramdist>


== Tumour–immune dynamics

@fig-trajectories shows what happens inside a single, average patient over time under the four different arms.

When we give the patient *no treatment*, the tumor just keeps growing until it hits its maximum size, which takes about five weeks. T cells can not fight the tumor because they die, and MDSC cells help the tumor to grow. Under *anti-PD-1*, T cells get an opportunity to multiply and fight the tumor. When the patient is on the *CCR2 antagonist*, the MDSC cells are successfully neutralized, but without enough T cell help, the tumor still grows a bit. Under *combination therapy*, both drugs are given to the patient. The T cells stay high, the MDSCs drop to zero, and the tumor gets shut down .
Using just one drug always leaves the tumor half-protected, which is why neither drug can completely stop the cancer on its own.
Based on Anderson et al. (@anderson_2024b_optimal_control): the combination therapy is the most effective, followed by anti-PD-1, then the CCR2 antagonist, and finally no treatment at all.

The “gaps” between the survival rates are smaller in this project. The reason is simple: Anderson et al. used complex, time-varying doses ($u_1(t)$ and $u_2(t)$) that were calculated to be the mathematically perfect schedule. However, in this case, the provided implementation is simplified by using constant doses. Since this GBM model isn’t using an “optimized” schedule, the survival differences between the groups are a bit smaller.

In a way, our studies are answering different questions using the same model. Anderson et al. were looking for the best possible outcome you could ever achieve, while this paper just compares how the treatments perform against each other at a fixed dose.

#figure(
  image("fig_trajectories.png", width: 100%),
  caption: [Reference-patient dynamics of glioma cells, T cells, and MDSCs 
    over 200 days under each treatment arm (mean parameters). Tumour and 
    T-cell axes are logarithmic.],
) <fig-trajectories>


== Survival outcomes

Kaplan-Meier survival curves based on the entire cohort are shown on the @fig-km. The four treatments split apart clearly. The patients who were on the “No treatment” arm result worst, with only about 28% of patients surviving without their tumor growing. The CCR2 drug helps a little bit, anti-PD-1 helps a lot, and the combination is the clear winner, with about 52% of patients staying progression-free by day 200.


#figure(
  image("km_corrected.png", width: 85%),
  caption: [Kaplan-Meier progression-free survival by treatment arm, with 
    95% confidence bands. The shaded regions are the Greenwood confidence 
    intervals.],
) <fig-km>

The exact numbers for each treatment are in @tab-results. The “hazard ratio” basically shows how much the drug lowered the risk of the tumor growing. The combination therapy cuts the risk in half compared to no treatment, while the CCR2 drug only gives a small benefit. According to the log-rank test, all of these improvements are statistically real, not just random.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    stroke: 0.5pt,
    inset: 6pt,
    table.header(
      [*Arm*], [*Events*], [*Median PFS*], [*PFS\@200d*], 
      [*Log-rank $p$*], [*Hazard ratio*],
    ),
    [No Treatment],    [699], [48.1 d], [0.28], [—], [—],
    [CCR2 Antagonist], [632], [56.7 d], [0.34], [$5.7 times 10^(-4)$], [0.83],
    [Anti-PD-1],       [533], [86.4 d], [0.45], [$2.5 times 10^(-15)$], [0.64],
    [Combination],     [462], [not reached], [0.52], [$3.3 times 10^(-29)$], [0.52],
  ),
  caption: [Per-arm survival statistics over 1000 patients. Hazard ratios 
    are relative to No Treatment; values below 1 indicate benefit.],
) <tab-results>

Visualization of these hazard ratios is shown on the forest plot in @fig-forest, and the final survival counts in @fig-pfs. Based on these analytical results, we can confidently say the drugs actually worked, with the combination therapy working the best.

#figure(
  image("fig_forest.png", width: 85%),
  caption: [Hazard ratios for each treatment arm relative to no treatment, 
    with 95% confidence intervals. All intervals lie below 1.],
) <fig-forest>

#figure(
  image("fig_pfs_bars.png", width: 100%),
  caption: [Progression-free survival rate at day 200 (left) and total 
    progression events (right) by treatment arm.],
) <fig-pfs>


== Solver efficiency

@fig-solver compares efficiency of the three math solvers during a run on a single patient. LSODA is the clear winner, followed by RK45, while the Radau solver is about ten times slower. LSODA wins because of the fact that the tumor cells and immune cells grow at very different speeds. As mentioned earlier, LSODA is powerful because of its ability to automatically switch its math strategy since it can tell if the data is stiff or non-stiff; that’s how it saves a ton of computing time.
RK45 is an explicit method best suited to
non-stiff problems, and is forced into very small step sizes whenever the
system becomes stiff. Radau is an implicit method designed for stiff
problems, but highly expensive because each step requires solving
a system of equations, which is wasteful when the system is non-stiff.
LSODA wins by combining both strategies.
The clinical simulation needs to be run a high number of times to derive a more reliable probability. So picking the fastest solver guarantees computational efficiency.

#figure(
  image("fig_solver.png", width: 80%),
  caption: [Wall-clock time per simulation for the three ODE solvers on a 
    reference patient (best of five runs). Absolute times are 
    machine-dependent; the ordering is stable.],
) <fig-solver>


= Conclusion

This thesis presents a computer simulation for a virtual clinical trial testing glioblastoma immunotherapy and successfully answers the three main questions for which the entire project was built. The project takes its main inspiration from the tumor-immune math model created by Anderson et al. @anderson_2024a_global_stability @anderson_2024b_optimal_control. The implemented code is organized into three main layers: the ODE system, creating the virtual patient cohort, and calculating the final survival statistics.
The cohort with 1000 patients goes through four different treatments and is also tested with three different numerical solvers to find the most efficient one.
The final results show that the model actually behaves like real biology under all four treatments (@fig-trajectories). LSODA is definitely the most efficient solver for this kind of system, making it the perfect choice when you need to run thousands of simulations (@fig-solver). Finally, combination therapy gives the best survival results, followed by anti-PD-1, and then the CCR2 drug (@fig-km @tab-results). Combination therapy being superior over other treatment groups was also one of the findings of Anderson et al.'s original paper @anderson_2024b_optimal_control. However, it is possible to advance this study in several ways.

For future work, the most obvious next step would be to stop using constant drug doses and switch to the optimized, time-varying dosing schedule. Making that change should widen the survival gaps between the treatments and result in the absolute best possible outcome the model predicts these therapies can achieve.


= Appendix


== Appendix A — GitHub Repository <appendix-a>





#bibliography(
  "references.bib",
  title: "References",
  style: "ieee",
)
