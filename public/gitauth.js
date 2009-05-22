function addUser()
{
  $("#add-user-link").hide();
  $("#add-user").slideDown("slow");
  return false;
}

function addRepo()
{
  $("#add-repo-link").hide();
  $("#add-repo").slideDown("slow");
  return false;
}

function hideUserForm()
{
  $("#add-user-link").show();
  $("#add-user").slideUp("slow");
}

function hideRepoForm()
{
  $("#add-repo-link").show();
  $("#add-repo").slideUp("slow");
}

$(function() {
  setTimeout(function() { $(".message").slideUp("slow"); }, 7500);
});