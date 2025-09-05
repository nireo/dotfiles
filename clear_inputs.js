// My university site doesn't contain any way to clear done exercises so to practice for
// exam clear each field forcefully.
document.querySelectorAll("input").forEach((input) => {
  if (input.type === "checkbox" || input.type === "radio") {
    input.checked = false;
  } else if (input.type !== "submit" && input.type !== "button") {
    input.value = "";
  }
});

document.querySelectorAll("textarea").forEach((textarea) => {
  textarea.value = "";
});

document.querySelectorAll("select").forEach((select) => {
  select.selectedIndex = 0;
});
