include_recipe "nfs"

service "nfsd" do
  action [:enable, :start]
end

duply_backup "nfs-exports" do
  source "/etc/exports"
end
