#let eval_table(benchmarks,n_reference_rows,caption,n_better_lower: 4) = {
  let best_scores = ()
  let i = 0
  while i < n_better_lower {
    let mins = 99999
    let j=0
    while j < benchmarks.len() {
      mins = calc.min(mins,benchmarks.at(j).vals.at(i))
      j = j + 1
    }
    best_scores.push(mins)
    i = i + 1
  }
  i = n_better_lower
  while i < benchmarks.at(0).vals.len(){
    let maxs = 0
    let j = 0
    while j < benchmarks.len() {
      maxs = calc.max(maxs,benchmarks.at(j).vals.at(i))
      j = j + 1
    }
    best_scores.push(maxs)
    i = i + 1
  }
  i = 0
  while i < benchmarks.at(0).vals.len(){
    let j = 0
    while j < benchmarks.len() {
      let tmp = [#benchmarks.at(j).vals.at(i)]
      if j < n_reference_rows {
        tmp = underline(tmp)
      }
      if benchmarks.at(j).vals.at(i) == best_scores.at(i) {
        tmp = [*#tmp*]
      }
      benchmarks.at(j).vals.at(i) = tmp
      j = j + 1
    }
    i = i + 1
  }
  let table_array = ()
  i = 0
  while i < benchmarks.len(){
    let j = 0
    table_array.push(benchmarks.at(i).name)
    while j < benchmarks.at(0).vals.len() {
      table_array.push([#benchmarks.at(i).vals.at(j)])
      j = j + 1
    }
    i = i + 1
  }
  figure(table(
    columns: (118pt, auto, auto,auto,auto,auto,auto,auto),
    stroke: none,
    [],table.vline(),table.cell(colspan: n_better_lower)[*Minore è meglio*],table.vline(),table.cell(colspan: benchmarks.at(0).vals.len() - n_better_lower)[*Maggiore è meglio*],
    table.hline(),
    [*Fonte*],[*Abs Rel*],[*Sq Rel*],[*RMSE*],[*RMSE log*],[*d1*],[*d2*],[*d3*],
    table.hline(),
    ..table_array
  ),caption: caption)
}