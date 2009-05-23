$(function() {
  setTimeout(function() { $(".message").slideUp("slow"); }, 7500);
});

function showForm(name)
{
  $("#add-" + name + "-link").hide();
  $("#add-" + name).slideDown("slow");
  return false;
}

function hideForm(name)
{
  $("#add-" + name + "-link").show();
  $("#add-" + name).slideUp("slow");
  return false;
}