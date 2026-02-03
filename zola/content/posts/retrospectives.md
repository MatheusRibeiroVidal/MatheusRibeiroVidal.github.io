+++
title = "Obsidian Journal Daily Tracker Overview"
date = "2025-05-09"
authors = ["Matheus"]

[taxonomies]
tags=["EN"]


[extra]
comment = false
read_time = true
toc = false
+++

# End-of-Year Retrospectives
These have always been kind of hard for me. I think that is maybe partly because I thought I had no basis on which to judge a whole year or period of time and partly because I usually could only remember the highlights, and was afraid that would not be a fair representation of that period of time.

On a kind of unrelated topic, I have been using [obsidian.md](https://obsidian.md/) as a note-taking and journaling tool for some months now and the flexibility it allows, specially with some wonderful community plugins such as [dataview](https://github.com/blacksmithgu/obsidian-dataview) is really great, specially with you want to do some more fancy stuff with your notes. 

That said, I created a small dataviewjs script that checks each daily journal note in my \daily folder for a property called "day rating" that ranges from 1-5 and displays each one in a grid, inspired by GitHub's contribution grid, to create an overview of the time period specified.

<div style="text-align: center;">
    <img src="/media/daily_tracker.png" alt="Daily Tracker" style="max-width: 100%; height: auto; margin: 10px;" />
</div>
Should be interesting to use this as an overview of the year in December.

{% note(clickable=true, hidden = true, header="Day Rating Grid") %}
```dataviewjs
const title = "2025";
const startOfRange = moment("2025-03-27");
const endOfRange = moment("2025-12-31");
const today = moment();
const totalDays = endOfRange.diff(startOfRange, "days") + 1;

let percentageDone = 0;
if (today.isBefore(startOfRange)) {
  percentageDone = 0;
} else if (today.isAfter(endOfRange)) {
  percentageDone = 100;
} else {
  const daysPassed = today.diff(startOfRange, "days") + 1;
  percentageDone = ((daysPassed / totalDays) * 100).toFixed(2);
}

const pages = dv.pages('"daily"').where(p => p["day rating"] !== undefined);
let ratingMap = new Map();
for (let page of pages) {
  const match = page.file.name.match(/\d{4}-\d{2}-\d{2}/);
  if (match) {
    ratingMap.set(match[0], page["day rating"]);
  }
}

let countBad = 0, countMeh = 0, countGood = 0, countPerfect = 0, countRated = 0;

let html = `
  <style>
    :root {
      --cell-size: clamp(5px, 1vw, 12px);
      --gap-size: 2px;
    }
    .daily-grid-container {
      text-align: center;
      margin-bottom: 0.5em;
    }
    .daily-grid-grid {
      display: grid;
      grid-template-columns: repeat(31, var(--cell-size));
      gap: var(--gap-size);
      justify-content: center;
      padding: 1em;
    }
    .daily-grid-cell {
      display: inline-block;
      width: var(--cell-size);
      height: var(--cell-size);
      border-radius: 3px;
      background-color: #aaa;
      border: 0.5px solid #999;
      box-sizing: border-box;
      cursor: pointer;
    }
    .daily-grid-good {
      background-color: green;
      border-color: green;
    }
    .daily-grid-great {
      background-color: #800080;
      border-color: #800080;
    }
    .daily-grid-bad {
      background-color: crimson;
      border-color: crimson;
    }
    .daily-grid-filled {
      background-color: #282726;
      border-color: #282726;
    }
    .daily-grid-today {
      outline: 2px solid #89b4fa;
    }
    .daily-grid-month {
      grid-column: 1 / -1;
      text-align: center;
      font-size: 0.7em;
      color: #575653;
      margin: 4px 0;
    }
    .daily-grid-tally {
      text-align: center;
      font-size: 0.85em;
      color: #aaa;
      margin-top: 1em;
    }
    .daily-grid-title {
      font-size: 1.5em;
      font-weight: bold;
      color: #0077b6;
      margin-bottom: 0.1em;
    }
    .daily-grid-subtitle {
      font-size: 1.1em;
      color: #555;
      margin-bottom: 0.5em;
    }
  </style>
  <div class="daily-grid-container">
    <div class="daily-grid-title">${title}</div>
    <div class="daily-grid-grid">
`;

let current = moment(startOfRange);
let currentMonth = current.month();
html += `<div class="daily-grid-month">${current.format("MMMM YYYY")}</div>`;

for (let i = 0; i < totalDays; i++) {
  if (current.month() !== currentMonth) {
    html += `<div class="daily-grid-month">${current.format("MMMM YYYY")}</div>`;
    currentMonth = current.month();
  }

  const dateStr = current.format("YYYY-MM-DD");
  const weekday = current.format("dddd");
  const notePath = `daily/${current.format("YYYY")}/${current.format("MM-MMMM")}/${dateStr}-${weekday}`;
  let rating = ratingMap.get(dateStr) ?? 3;

  let classes = "daily-grid-cell";
  const isPast = current.isBefore(today, "day");
  const isToday = current.isSame(today, "day");
  const isBeforeOrToday = isPast || isToday;

  if (rating >= 5) {
    classes += " daily-grid-great";
    if (isBeforeOrToday) countPerfect++;
  } else if (rating >= 4) {
    classes += " daily-grid-good";
    if (isBeforeOrToday) countGood++;
  } else if (rating <= 2) {
    classes += " daily-grid-bad";
    if (isBeforeOrToday) countBad++;
  } else if (isBeforeOrToday) {
    classes += " daily-grid-filled";
    countMeh++;
  }

  if (isToday) {
    classes += " daily-grid-today";
  }

  if (isBeforeOrToday) countRated++;

  const onClick = isBeforeOrToday ? `app.workspace.openLinkText('${notePath}', '')` : null;
  html += `<div class="${classes}" ${onClick ? `onclick="${onClick}"` : ''} title="${dateStr}-${weekday}"></div>`;

  current.add(1, "day");
}

html += `</div>`;

const safeDiv = (count) =>
  countRated > 0 ? ((count / countRated) * 100).toFixed(1) + "%" : "0.0%";

html += `
  <div class="daily-grid-tally">
    <strong>Results (of ${countRated} days):</strong><br>
    🟥 Bad: ${countBad} (${safeDiv(countBad)}) |
    😐 Meh: ${countMeh} (${safeDiv(countMeh)}) |
    ✅ Good: ${countGood} (${safeDiv(countGood)}) |
    💜 Perfect: ${countPerfect} (${safeDiv(countPerfect)})
  </div>
</div>
`;

dv.container.innerHTML = html;

```
{% end %}