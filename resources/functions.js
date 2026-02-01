export function set_diff(set1, set2) {
	set1.forEach( (x) => set2.has(x) ? set1.delete(x) : 0 );
	return set1;
}

export function sort_overall_first(a, b) {
  a = a.toString();
  b = b.toString();
  const comesFirst = ["Ogółem", "Ndt."];
  if (comesFirst.includes(a) && comesFirst.includes(b)) {
    return 0;
  } else if (comesFirst.includes(a)) {
    return -1;
  } else if (comesFirst.includes(b)) {
    return 1;
  } else {
    return a.localeCompare(b);
  }
}

export function sort_numeric(a, b) {
  return a - b;
}

export function download_csv(data, filename) {
  const blob = new Blob([data], {type: "text/csv;charset=utf-8"});
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
};

export function sequence(from, to, by) {
	const seq = [];
	for (let i = from; i < (to + by); i = i + by) {
		seq.push(i);
	}
	return seq;
}
