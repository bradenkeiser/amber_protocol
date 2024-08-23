library('ggplot2','stringr')
library('ggplot2')
rm(list=ls())
args <- commandArgs(trailingOnly=TRUE)
#args <- c('/home/deck/xylanase/Thai_SC_xyl-328-results/x11p', 'tpr-protein.pdb','trj-protein.dcd',
#          'x11p','328','1')
args <- c('h:/HMG/tested_wt/liginfo_new')
setwd(args[1])

protein <- 'WT' # WT
sim_time <- 20 # 200
test_num <- '1' # 1

hmg <- read.table('hmg_rmsd.xvg')
nap <- read.table('nap_rmsd.xvg')

frames <- hmg[,1]
my_breaks <- seq(0,sim_time, by = sim_time/4); print(breaks[2:5])

data <- data.frame(frames)
data$nap <- nap[,2]
data$hmg <- hmg[,2]
data$reframe <- data$frames/(length(frames)/sim_time)

fig_title <- paste(protein,' in ', sim_time,'ns at 300K',sep = '')
hmg_fig <- ggplot2::ggplot(data, aes(x=reframe, color=protein)) +
  geom_line(aes(y=hmg, color = protein), lwd=1) +
  labs(x="Time (ns))", y = "RMSD (Å)", title=paste('RMSD of ', fig_title, sep = '')) +
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(),
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1)) +
  scale_x_continuous(breaks = my_breaks) +
  scale_y_continuous(breaks=seq(0,5,by=1), limits = c(0,5),
                     sec.axis = dup_axis(name = NULL)) + 
  scale_color_manual(values = 'blue'); hmg_fig



fig_title <- paste(protein,' in ', sim_time,'ns at 300K')
nap_fig <- ggplot2::ggplot(data, aes(x=reframe, color=protein)) +
  geom_line(aes(y=nap, color = protein), lwd=1) +
  labs(x="Time (ns))", y = "RMSD (Å)", title=paste('RMSD of ', fig_title, sep = '')) +
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(),
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1)) +
  scale_x_continuous(breaks = my_breaks) +
  scale_y_continuous(breaks=seq(0,5,by=1), limits = c(0,5),
                     sec.axis = dup_axis(name = NULL))  + 
  scale_color_manual(values = 'red'); nap_fig
fig_title <- paste(protein,' in ', sim_time,'ns at 300K')

dual_fig <- ggplot2::ggplot(data, aes(x=reframe, color=protein)) +
  geom_line(aes(y=nap, color = 'NAP'), lwd=1) +
  geom_line(aes(y=hmg, color = 'HMG'), lwd=1) +
  labs(x="Time (ns))", y = "RMSD (Å)", title=paste('RMSD of ', fig_title, sep = '')) +
  theme_classic() + theme(legend.position = 'top', legend.title = element_blank(),
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 18), legend.key.size = unit(1,'cm'), 
                          axis.text = element_text(face='bold', size=20, color = 'black'),
                          axis.title = element_text(face='bold', size = 20),
                          plot.title = element_text(face='bold', hjust=0.5, size = 20),
                          panel.border = element_rect(fill = NA, linewidth=1)) +
  scale_x_continuous(breaks = my_breaks) +
  scale_y_continuous(breaks=seq(0,5,by=1), limits = c(0,5),
                     sec.axis = dup_axis(name = NULL)) + 
  scale_color_manual(values = c('blue', 'red')); dual_fig

ggsave(paste(protein,'-',test_num,'_hmg_rmsd.png'), hmg_fig, width = 10, height = 8)
ggsave(paste(protein,'-',test_num,'_nap_rmsd.png'), nap_fig, width = 10, height = 8)
ggsave(paste(protein,'-',test_num,'_hmg-nap_rmsd.png'), dual_fig, width = 10, height = 8)