library('ggplot2', 'stringr')
rm(list=ls())
args <- commandArgs(trailingOnly=TRUE)
print('Args should be: PWD, MUT, PBSA_DDG')
args=c('g:/HMG/tested_wt/pbsa_results', 'WT')
print(paste0('Arguments: ', args))
setwd(args[1])


dg <- read.table('total_ddg.dat', header = TRUE, sep = ',', 
                 as.is = TRUE) #MUST DO AS IS OTHERWISE IT SORTS RESNAMES ALPHABETICALLY


decomp_deltas <- read.table('decomp_deltas.dat', header = TRUE, as.is=TRUE)

dg$TOTAL <- decomp_deltas$TOTAL

sum(decomp_deltas$TOTAL)
options(stringsAsFactors = FALSE)
dg_df <- data.frame(res = dg$Residue[1:length(dg$TOTAL)-1], TOTAL = dg$TOTAL[1:length(dg$TOTAL)-1], stringsAsFactors = FALSE)
residues <- (stringr::str_split(dg_df$res, " ", simplify = TRUE))
for (i in 1:length(dg_df$res)) {
  new_var <- stringr::str_split(dg_df$res[i], " ", simplify = TRUE)
  #print(paste0('this is the new value to add to the residue list: ', new_val))
  if ( new_var[,1] == "HID") {
    new_var[,1] = "HIS"
  } else if (new_var[,1] == "CYX") {
    new_var[,1] = "CYS"
  }
  
  if (new_var[,2] != '' ) {
    nummy <- new_var[,2]
  } else if (new_var[,3] != '') {
      nummy <- new_var[,3]
      } else if (new_var[,4] != '') {
        nummy <- new_var[,4]
      }
  new_line <- paste(new_var[,1], nummy,sep = " ")
  if (exists("res_list")==TRUE) { 
    res_list <- append(res_list, new_line)
  } else if (exists("res_list") == FALSE) {
      res_list <- c(new_line)
    }
  if (dg_df$TOTAL[i] < 0.05 & dg_df$TOTAL[i] > -0.05) {
      print('data too inconsequential; will not be added to graph')
  } else {
      if (exists("fin") == TRUE & exists("new_reslist")==TRUE) {
            print('data sufficiently large, adding to graph')
            new_row <- c(toString(dg_df$res[i]), dg_df$TOTAL[i])
            fin <- rbind(fin, new_row)
            new_reslist<-append(new_reslist,new_line)
      } else if (exists("fin") == FALSE & exists("new_reslist")==FALSE) {
          print('making fin dataframe')
          fin <- data.frame(fin_res = dg_df$res[i], fin_tot = dg_df$TOTAL[i])
          new_reslist <- c(new_line)
      }
    }
}


my_test <-function(x) { 
  replace_string <- function(x) {
    if (x[1] == "CYX") {
      x[1] <- "CYS"
    } else if (x[1] %in% c("HID", "HIP")) {
      x[1] <- "HIS"
    }
    return(x)
  }
  }
test_reres <- ifelse(dg_df$res == "CYX", "CYS", 
                    ifelse(dg_df$res %in% c("HID","HIP"), "HIS", dg_df$res))
res_list <- factor(res_list,levels=res_list)

dg_df$res <- factor(dg_df$res,levels=dg_df$res)


mut <- args[2]
write.table(dg_df, paste(mut, 'PBDECOMP_FULL.dat', sep = '_'), sep = "\t",
row.names=FALSE, col.names=TRUE)

new_reslist <- factor(new_reslist,levels=new_reslist)
fin$fin_res <- new_reslist
fin$fin_tot <- as.numeric(fin$fin_tot)
write.table(fin, paste(mut, 'PBDECOMP_TRUNK.dat', sep = '_'), sep = "\t",
row.names=FALSE, col.names=TRUE)

mini <- signif(min(fin$fin_tot)-0.25, 3); maxi <- signif(max(fin$fin_tot)+0.25,3)
dg_fig <- ggplot(fin, aes(x=new_reslist, y = fin_tot, fill = fin_res, label = fin_res)) +
  geom_bar(stat='identity') + 
  labs(x="Residue", y = "DG Totals", title=paste(mut, 'Total DDG Decomposition 300K Simulation', sep = " ")) +
  theme_classic() + theme(legend.position = 'none', legend.title = element_blank(), 
                          legend.background = element_rect(fill = NA, color= NA),
                          legend.key = element_rect(fill = "transparent", color= NA),
                          legend.text = element_text(size = 10),
                          axis.text = element_text(face='bold', size=12), 
                          axis.title = element_text(face='bold'), 
                          plot.title = element_text(face='bold', hjust=0.5), 
                          panel.border = element_rect(fill = NA, linewidth=1), 
                          axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 9)) + #+ 
  scale_y_continuous(limits = c(mini,maxi), 
                     breaks = seq(mini,maxi,by = 0.5),
                     sec.axis = dup_axis(name = NULL)) + 
  scale_x_discrete(breaks=new_reslist)
data_values<-ggplot_build(dg_fig)
x_limits<-data_values$layout$panel_params[[1]]$x.range
xmax <- max(x_limits)
y_limits<-data_values$layout$panel_params[[1]]$y.range
ymax<-max(y_limits)

total_ddg <- sum(fin$fin_tot)

dg_fig <- dg_fig + 
  annotate('text', x = xmax*.60, y = ymax*.6, hjust=0, vjust=1,
           label = paste('Total Decomp DDG =',total_ddg,'kcal/mol', sep=' '), 
           color = "blue", fontface = 'bold'); dg_fig

png(paste(mut,"decomp_results.png", sep = '_'),
    width = 500, height=400, pointsize = 15, 
    type = 'cairo')
dg_fig
dev.off()
