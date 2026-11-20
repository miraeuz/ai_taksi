import 'package:flutter/material.dart';
import 'tg_theme.dart';

class TgAvatar extends StatelessWidget {
  final String label;
  final double size;
  final IconData? icon;
  final Color? color;
  const TgAvatar({super.key,required this.label,this.size=44,this.icon,this.color});
  @override Widget build(BuildContext context){
    final palette=<Color>[const Color(0xFF4A97DC),const Color(0xFF8F70D9),
      const Color(0xFF47A7A0),const Color(0xFFE5A34A),const Color(0xFFCB7891)];
    final c=color??palette[label.codeUnits.fold(0,(a,b)=>a+b)%palette.length];
    final chunks=label.trim().split(RegExp(r'\s+'));
    final initials=chunks.length>1?'${chunks.first.substring(0,1)}${chunks.last.substring(0,1)}':
      label.isEmpty?'A':label.substring(0,1);
    return Container(width:size,height:size,alignment:Alignment.center,
      decoration:BoxDecoration(shape:BoxShape.circle,
        gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,
          colors:[c,c.withValues(alpha:.75)])),
      child:icon!=null?Icon(icon,color:Colors.white,size:size*.46):Text(initials.toUpperCase(),
        style:TextStyle(color:Colors.white,fontSize:size*.35,fontWeight:FontWeight.w600)));
  }
}

class TgSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const TgSurface({super.key,required this.child,this.padding=const EdgeInsets.all(16),this.radius=16});
  @override Widget build(BuildContext context)=>Container(
    decoration:BoxDecoration(color:context.pageSurface,
      borderRadius:BorderRadius.circular(radius),
      border:Border.all(color:context.isNight?const Color(0xFF263542):const Color(0xFFE7EAEE),width:.75)),
    padding:padding,child:child);
}

class TgSectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  const TgSectionTitle(this.title,{super.key,this.trailing,this.onTap});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.fromLTRB(2,22,2,10),
    child:Row(children:[Expanded(child:Text(title,style:TextStyle(fontSize:17.5,
      fontWeight:FontWeight.w700,letterSpacing:-.3,color:context.primaryInk))),
      if(trailing!=null)TextButton(onPressed:onTap,child:Text(trailing!,
        style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600)))]));
}

class TgRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading,trailing;
  final VoidCallback? onTap;
  final bool divider;
  const TgRow({super.key,required this.title,this.subtitle,this.icon,this.leading,
    this.trailing,this.onTap,this.divider=true});
  @override Widget build(BuildContext context)=>Column(children:[
    InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),child:Padding(
      padding:const EdgeInsets.symmetric(horizontal:1,vertical:11),
      child:Row(children:[
        leading??(icon!=null?TgAvatar(label:title,size:43,icon:icon):const SizedBox.shrink()),
        if(leading!=null||icon!=null)const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(title,style:TextStyle(color:context.primaryInk,fontWeight:FontWeight.w600,fontSize:14.5),
            maxLines:2,overflow:TextOverflow.ellipsis),
          if(subtitle!=null)...[const SizedBox(height:4),Text(subtitle!,
            style:TextStyle(color:context.secondaryInk,fontSize:12.5),maxLines:2,
            overflow:TextOverflow.ellipsis)]
        ])),
        if(trailing!=null)trailing! else if(onTap!=null)Icon(Icons.chevron_right_rounded,
          color:context.secondaryInk,size:20),
      ]))),
    if(divider)Divider(height:1,indent:(leading!=null||icon!=null)?56:0),
  ]);
}

class TgBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  const TgBadge(this.text,{super.key,this.color,this.icon});
  @override Widget build(BuildContext context){final c=color??context.accent;
    return Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
      decoration:BoxDecoration(color:c.withValues(alpha:context.isNight ? 0.17 : 0.10),
        borderRadius:BorderRadius.circular(8)),
      child:Row(mainAxisSize:MainAxisSize.min,children:[if(icon!=null)...[
        Icon(icon,size:12,color:c),const SizedBox(width:4)],
        Text(text,style:TextStyle(color:c,fontSize:11,fontWeight:FontWeight.w700))]));
  }
}

class TgPagePadding extends StatelessWidget {
  final List<Widget> children;
  const TgPagePadding({super.key,required this.children});
  @override Widget build(BuildContext context)=>ListView(
    physics:const BouncingScrollPhysics(),padding:const EdgeInsets.fromLTRB(16,14,16,26),
    children:children);
}

class TgEmptyState extends StatelessWidget {
  final IconData icon;
  final String title,subtitle;
  const TgEmptyState({super.key,required this.icon,required this.title,required this.subtitle});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(25),
    child:Column(children:[Icon(icon,size:54,color:context.accent.withValues(alpha:.65)),
      const SizedBox(height:14),Text(title,style:TextStyle(fontWeight:FontWeight.w700,
        fontSize:17,color:context.primaryInk)),const SizedBox(height:7),
      Text(subtitle,textAlign:TextAlign.center,style:TextStyle(color:context.secondaryInk,
        height:1.5,fontSize:13))]));
}

class TgDemoLabel extends StatelessWidget {
  const TgDemoLabel({super.key});
  @override Widget build(BuildContext context)=>const TgBadge('OFFLINE DEMO',icon:Icons.science_outlined);
}

void tgMessage(BuildContext context,String message){
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
}

Future<T?> tgPicker<T>(BuildContext context, {
  required String title,
  required List<T> values,
  required String Function(T) label,
  String? Function(T)? subtitle,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final sheetHeight = MediaQuery.sizeOf(sheetContext).height * .70;
      return SafeArea(
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 8, 7),
                child: Row(children: [
                  Expanded(child: Text(title,
                    style: const TextStyle(fontSize: 19,fontWeight: FontWeight.w700))),
                  IconButton(icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (c, i) => ListTile(
                    leading: Icon(Icons.location_on_outlined,
                      color: Theme.of(c).colorScheme.primary),
                    title: Text(label(values[i])),
                    subtitle: subtitle == null ? null : Text(subtitle(values[i]) ?? ''),
                    onTap: () => Navigator.pop(sheetContext,values[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
