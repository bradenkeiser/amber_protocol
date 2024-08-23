library('bio3d','ggplot2','stringr')
library('ggplot2')
rm(list=ls())
args <- commandArgs(trailingOnly=TRUE)
#args <- c('/home/deck/xylanase/Thai_SC_xyl-328-results/x11p', 'tpr-protein.pdb','trj-protein.dcd',
#          'x11p','328','1')

print('the below args will be iterated 1-5, change as needed')
args <- c('h:/HMG/tested_wt/liginfo_new', 'tpr-protein.pdb', 'trj-protein.dcd', 'WT', '300', '1')
setwd(args[1])
tpr <- read.pdb(args[2])
trj <- read.dcd(args[3])
protein <- toupper(args[4]); temp <- args[5]; test = args[6]
mut.inds <- atom.select(tpr, elety='CA')
xyz <- fit.xyz(fixed = tpr$xyz, mobile = trj,
               fixed.inds = mut.inds$xyz, mobile.inds = mut.inds$xyz)

residues <- c(seq(1,358), seq(360,785))

frames <- seq(1,length(xyz[,1]))
time <- round((max(frames)-1)/100,1)

print(paste0('there are ', max(frames),' frames representing ',time,'ns'))
rmsd <- rmsd(a = xyz[1,mut.inds$xyz], b = xyz[,mut.inds$xyz])
rg<- rgyr(xyz)
rf <- rmsf(xyz[,mut.inds$xyz])



rmsd_name <- paste0(protein, '_rmsd')
rmsf_name <- paste0(protein,'_rmsf')
rog_name <- paste0(protein,'_rog')


rm_df <- data.frame(frames); rm_df[[rmsd_name]] <- rmsd
rg_df <- data.frame(frames); rg_df[[rog_name]] <- rg
rf_df <- data.frame(resid = residues); rf_df[[rmsf_name]] <- rf

write.table(rf_df, paste0('rmsf-',tolower(protein),'-',temp,'-',test, '.xvg'), sep = ' ')
write.table(rm_df, paste0('rmsd-',tolower(protein),'-',temp,'-',test, '.xvg'), sep = ' ')
write.table(rg_df, paste0('rog-',tolower(protein),'-',temp,'-',test, '.xvg'), sep = ' ')
print("data processing complete, making plots...")

fig_title = paste0(protein,' in ', time, 'ns',' at ',temp, ' - test',test); fig_title


rm_fig <- ggplot2::ggplot(rm_df, aes(x=frames, color=protein)) +
 #geom_line(aes(y=X11P, color="X11P"), lwd=1) +
  geom_line(aes(y=rmsd, color = protein), lwd=1) +
  labs(x="Frame (1000 = 10ns)", y = "RMSD (Å)", title=paste('RMSD of ', fig_title, sep = '')) +
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(),
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1)) +
  scale_x_continuous(breaks = seq(0,10000, by = 1000)) +
  scale_y_continuous(breaks=seq(0,5,by=1), limits = c(0,5),
                     sec.axis = dup_axis(name = NULL)); rm_fig



rg_fig <- ggplot(rg_df, aes(x=frames, color=protein)) + 
  #geom_line(aes(y=X11P, color="X11P"), lwd=1) +
  geom_line(aes(y=rg, color = protein), lwd=1) +
  labs(x="Frame (1000 = 10ns)", y = "RoG (Å)", title=paste('RoG of ',fig_title, sep = '')) + 
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(), 
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1)) +
  scale_x_continuous(breaks = seq(0,10000, by=1000))+
  scale_y_continuous(sec.axis = dup_axis(name=NULL)); rg_fig# + 
#scale_color_manual(values = c('DarkGreen'),
#                  breaks = c(tpr_info[2]))           


ggsave(paste0('rmsd-',tolower(protein),'-',temp,'-',test,'.png'), rm_fig, width=10, height = 8)


ggsave(paste0('rog-',tolower(protein),'-',temp,'-',test,'.png'), rg_fig, width=10, height = 8)


allpoints <- rf_df[[rmsf_name]]
my_breaks <- c(seq(1,358, by = 100),seq(360,785,  by = 100))
print(my_breaks)
my_rmsf<- seq(0,max(allpoints), by = 0.5)
rf_fig <- ggplot(rf_df, aes(x=resid, color=toupper(protein))) + 
  #geom_line(aes(y=rf_base, color="WT"), lwd=1) + 
  geom_line(aes(y=rf, color = protein), lwd=1) +
  geom_vline(xintercept = 358) + 
  labs(x="Residue", y = "RMSF (Å)", title=paste0('RMSF of ', fig_title)) + 
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(), 
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1), 
                          axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 15)) +
  scale_x_continuous(breaks = my_breaks) + 
  scale_y_continuous(breaks=my_rmsf, limits = c(0,0.25+max(allpoints)), 
                     sec.axis = dup_axis(name=NULL)); rf_fig
ggsave(paste0('rmsf-',tolower(protein),'-',temp,'-',test,'.png'), rf_fig, width=10, height=8)
