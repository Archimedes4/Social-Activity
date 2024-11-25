const  GitHubProfileStatus = require('github-profile-status').GitHubProfileStatus;
const GITHUB_ACCESS_TOKEN = "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"

async function changeToSleep() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  await profileStatus.set({
    emoji: ':sleeping:',
    message: 'Sleeping for HOURS hours!'
  });
}

async function changeToSchool() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  await profileStatus.set({
    emoji: ':school_satchel:',
    message: 'At school for HOURS hours!'
  });
}

async function changeToWalking() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  await profileStatus.set({
    emoji: ':bus:',
    message: 'Transiting for HOURS hours!'
  });
}

async function changeToCoding() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  const result = await profileStatus.set({
    emoji: ':man_technologist:',
    message: 'Coding for HOURS hours!'
  });
}

async function changeToNotCoding() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  await profileStatus.set({
    emoji: ':house:',
    message: "Not coding for HOURS hours!"
  });
}

async function changeToVacation() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });

  // set your the github profile status
  await profileStatus.set({
    emoji: ':palm_tree:',
    message: "On vacation"
  });
}

async function clearStatus() {
  const profileStatus = new GitHubProfileStatus({
    token: GITHUB_ACCESS_TOKEN,
  });
  await profileStatus.clear();
}

clearStatus()
//Main