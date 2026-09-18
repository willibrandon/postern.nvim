-- The Postern server for Neovim: where the binary is, and how to fetch it.
--
-- `postern` on the PATH is used when it is there. Otherwise the binary
-- `:PosternInstall` fetched into Neovim's data directory is used, and until
-- one exists the server does not start.
local M = {}

local repo = "willibrandon/postern"

--- The directory the fetched binary lives in.
function M.dir()
  return vim.fs.joinpath(vim.fn.stdpath("data"), "postern")
end

--- The fetched binary's path, whether or not it exists yet.
function M.installed()
  local name = vim.fn.has("win32") == 1 and "postern.exe" or "postern"
  return vim.fs.joinpath(M.dir(), name)
end

--- The command the server starts with: `postern` on the PATH, else the
--- fetched binary, else `postern` for the client to report as missing.
function M.cmd()
  if vim.fn.executable("postern") == 1 then
    return { "postern" }
  end
  local installed = M.installed()
  if vim.fn.executable(installed) == 1 then
    return { installed }
  end
  return { "postern" }
end

local function platform()
  local os = vim.uv.os_uname()
  local system = ({ Linux = "linux", Darwin = "darwin", Windows_NT = "win32" })[os.sysname]
  local machine = os.machine:lower()
  local arch = (machine == "x86_64" or machine == "amd64") and "x64"
    or (machine == "aarch64" or machine == "arm64") and "arm64"
    or nil
  if not system or not arch then
    return nil, ("postern has no release for %s %s"):format(os.sysname, os.machine)
  end
  return system, arch
end

--- Runs `cmd` and returns its output, or nil and why not.
local function run(cmd, what)
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    return nil, ("could not %s: %s"):format(what, vim.trim(result.stderr or ""))
  end
  return result.stdout or ""
end

--- The body at `url`.
local function fetch(url)
  return run({ "curl", "-fsSL", url }, "fetch " .. url)
end

--- Fetches `url` into the file at `path`.
local function download(url, path)
  local out, err = run({ "curl", "-fsSL", url, "-o", path }, "fetch " .. url)
  return out ~= nil, err
end

--- The SHA-256 of the file at `path` as hex, from the system's own tool,
--- since Vim's `sha256()` stops at the first NUL byte of a string.
function M.sha256(path)
  local cmd = vim.fn.executable("sha256sum") == 1 and { "sha256sum", path }
    or vim.fn.executable("shasum") == 1 and { "shasum", "-a", "256", path }
    or vim.fn.has("win32") == 1 and { "certutil", "-hashfile", path, "SHA256" }
  if not cmd then
    return nil, "no sha256sum, shasum or certutil to check the download with"
  end
  local out, err = run(cmd, "check " .. path)
  if not out then
    return nil, err
  end
  -- certutil puts the hash on a line of its own, in older versions with a
  -- space between the bytes.
  return (out:lower():gsub("[ \r]", "")):match(("%x"):rep(64))
end

--- The hash SHA256SUMS lists for `asset`.
local function listed(sums, asset)
  for line in sums:gmatch("[^\n]+") do
    local hash, name = line:match("^(%x+)%s+%*?(.-)%s*$")
    if name == asset then
      return hash
    end
  end
end

--- Fetches the release binary for this platform into the data directory,
--- verifying the checksum the release carries, and returns its path. The
--- latest release, or `version` such as "0.2.1".
function M.install(version)
  local system, arch = platform()
  if not system then
    return nil, arch
  end
  if not version then
    local body, err = fetch(("https://api.github.com/repos/%s/releases/latest"):format(repo))
    if not body then
      return nil, err
    end
    version = vim.json.decode(body).tag_name:gsub("^v", "")
  end
  local asset = ("postern-%s-%s-%s%s"):format(version, system, arch, system == "win32" and ".exe" or "")
  local base = ("https://github.com/%s/releases/download/v%s"):format(repo, version)
  local dir = M.dir()
  vim.fn.mkdir(dir, "p")
  local tmp = vim.fs.joinpath(dir, asset .. ".part")
  local ok, err = download(base .. "/" .. asset, tmp)
  if not ok then
    return nil, err
  end
  local sums, sums_err = fetch(base .. "/SHA256SUMS")
  if not sums then
    return nil, sums_err
  end
  local actual, sha_err = M.sha256(tmp)
  if not actual then
    os.remove(tmp)
    return nil, sha_err
  end
  if actual ~= listed(sums, asset) then
    os.remove(tmp)
    return nil, ("the checksum of %s does not match the release's SHA256SUMS"):format(asset)
  end
  local path = M.installed()
  os.remove(path)
  local renamed, rename_err = vim.uv.fs_rename(tmp, path)
  if not renamed then
    return nil, rename_err
  end
  vim.uv.fs_chmod(path, 493)
  return path
end

return M
