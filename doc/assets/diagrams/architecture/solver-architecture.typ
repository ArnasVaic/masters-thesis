#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

// Filled diamond on the owner's end, UML composition
#let owns = (marks: ((inherit: "diamond", fill: auto, size: 5), none))

#let cls(name, stereotype: none, ..members) = [
  #if stereotype != none [`<<`#stereotype`>>` \ ]
  *#raw(name)*
  #if members.pos().len() > 0 {
    align(left, members.pos().map(raw).join(linebreak()))
  }
]

#let iface(name, ..members) = cls(name, stereotype: "interface", ..members)

// Realization edge from an implementation stacked below its interface,
// routed along a shared vertical line left of the interface
#let realizes(impl, interface) = {
  let bus = (rel: (-8pt, 0pt), to: str(interface) + ".west")
  edge(impl, (bus, "|-", str(impl) + ".west"), bus, interface, "--|>")
}

#figure(
  {
    set text(size: 8pt)
    diagram(
      node-stroke: 0.8pt,
      node-fill: rgb("#e9e9e9"),
      node-corner-radius: 3pt,
      node-inset: 6pt,
      spacing: (24pt, 20pt),
      edge-stroke: 0.7pt,
      mark-scale: 70%,

      // Rezultatas
      node((0, 0), name: <batch-range>, cls(
        "BatchRange",
        "ResultBatch iteratorius",
      )),
      node((1, 0), name: <result>, iface(
        "IResult",
        "+ metadata() : ResultMetadata",
        "+ batches(batch_size : size_t)",
        "    : BatchRange",
        "+ all() : ResultBatch",
      )),
      node((2, 0), name: <result-batch>, cls(
        "ResultBatch",
        "+ values() : xarray<double>",
        "+ times() : xarray<double>",
      )),
      edge(<result>, <batch-range>, "-->", [`batches`], label-side: right),
      edge(<result>, <result-batch>, "-->", [`all`], label-side: left),

      // Sprendiklis ir jo įvestys
      node((0, 1), name: <solution-state>, cls(
        "SolutionState",
        "+ c : xarray<double>[5]",
      )),
      node((1, 1), name: <solve>, cls(
        "solve",
        stereotype: "function",
        "+ solve(config, ic, params)",
        "    : IResult",
      )),
      node((2, 1), name: <model-params>, cls(
        "ModelParameters",
        "+ D : xarray<double> (5)",
        "+ k : xarray<double> (3)",
      )),
      edge(<solve>, <result>, "-->", [grąžina], label-side: right),
      edge(<solution-state>, <solve>, "-->", [`ic`], label-side: left),
      edge(<model-params>, <solve>, "-->", [`params`], label-side: right),

      node((0, 2), name: <solver-state>, cls(
        "SolverState",
        "+ solution : SolutionState",
        "+ time : double",
        "+ step : size_t",
        "+ is_final : bool",
      )),
      node((1, 2), name: <solver-config>, cls(
        "SolverConfig",
        "+ discretization : Discretization",
        "+ step : ITimeStep",
        "+ brake : IBrake",
        "+ capture : CaptureConfig",
        "+ stoichiometry : xarray<double>",
      )),
      node((2, 2), name: <disc>, cls(
        "Discretization",
        "+ physical_space_w : double",
        "+ physical_space_h : double",
        "+ mesh_res_x : size_t",
        "+ mesh_res_y : size_t",
      )),
      edge(<solver-state>, <solution-state>, ..owns),
      edge(<solver-config>, <solve>, "-->", [`config`], label-side: left),
      edge(<solver-config>, <disc>, ..owns),

      // Sprendiklio konfigūracija
      node((0, 3), name: <time-step>, iface(
        "ITimeStep",
        "+ advance(s : SolverState)",
        "    : double",
      )),
      node((1, 3), name: <capture-config>, cls(
        "CaptureConfig",
        "+ channels : uint32_t",
        "+ reducer : IReducer",
        "+ trigger : ITrigger",
        "+ sink : ISink",
      )),
      node((2, 3), name: <brake>, iface(
        "IBrake",
        "+ shouldBrake(s : SolverState)",
        "    : bool",
      )),
      edge(<solver-config>, (1, 2.55), (0, 2.55), <time-step>, ..owns),
      edge(<solver-config>, <capture-config>, ..owns),
      edge(<solver-config>, (1, 2.55), (2, 2.55), <brake>, ..owns),

      // Sprendinio fiksavimas
      node((0, 4), name: <trigger>, iface(
        "ITrigger",
        "+ shouldCapture(s : SolverState)",
        "    : bool",
      )),
      node((1, 4), name: <reducer>, iface(
        "IReducer",
        "+ reduce(s : SolutionState,",
        "    channels, disc)",
        "    : xarray<double>",
      )),
      node((2, 4), name: <sink>, iface(
        "ISink",
        "+ write(frame : xarray<double>,",
        "    t : double)",
        "+ finish() : IResult",
      )),
      edge(<capture-config>, (1, 3.55), (0, 3.55), <trigger>, ..owns),
      edge(<capture-config>, <reducer>, ..owns),
      edge(<capture-config>, (1, 3.55), (2, 3.55), <sink>, ..owns),

      node((0.1, 5), name: <stride>, cls("StrideTrigger", "+ stride : size_t")),
      node((0.1, 6), name: <last-frame>, cls("LastFrameTrigger")),
      realizes(<stride>, <trigger>),
      realizes(<last-frame>, <trigger>),

      node((1.1, 5), name: <concentration>, cls("ConcentrationFieldReducer")),
      node((1.1, 6), name: <density>, cls("DensityFieldReducer")),
      node((1.1, 7), name: <molar-quantity>, cls("MolarQuantityReducer")),
      node((1.1, 8), name: <total-mass>, cls("TotalMassReducer")),
      realizes(<concentration>, <reducer>),
      realizes(<density>, <reducer>),
      realizes(<molar-quantity>, <reducer>),
      realizes(<total-mass>, <reducer>),

      node((2.1, 5), name: <in-memory>, cls("InMemorySink", "+ capacity : size_t?")),
      node((2.1, 6), name: <hdf5>, cls("HDF5Sink", "+ path : string")),
      realizes(<in-memory>, <sink>),
      realizes(<hdf5>, <sink>),
    )
  },
  caption: [ UML klasių diagrama, sprendiklio `solve` įvestys, konfigūracija ir rezultatas. ]
) <solver-architecture-diagram>
